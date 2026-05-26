import pycuda.autoinit
import pycuda.driver as cuda
from pycuda.compiler import SourceModule
from fastapi import FastAPI, File, UploadFile, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
import cv2
import numpy as np
import base64

app = FastAPI(title="UPSGlam GPU Service")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 1. Kernels CUDA
codigo_kernel = """
// Memoria constante para los filtros (max 125x125 = 15625 floats)
__constant__ float d_filtro[15625];

// --- KERNEL 1: Convolución 1D (Motion Blur / Nitidez) ---
__global__ void convolucionGPU_1D(const unsigned char* input, unsigned char* output, int width, int height, int filterSize) {
    long long tid = threadIdx.x + blockIdx.x * blockDim.x;
    long long totalPixels = (long long)width * height;

    if (tid < totalPixels) {
        int x = tid % width;
        int y = tid / width;
        int offset = filterSize / 2;

        if (x >= offset && x < width - offset && y >= offset && y < height - offset) {
            float suma = 0.0f;

            for (int fy = -offset; fy <= offset; ++fy) {
                for (int fx = -offset; fx <= offset; ++fx) {
                    int imgY = y + fy;
                    int imgX = x + fx;
                    int filterY = fy + offset;
                    int filterX = fx + offset;

                    int imgIndex = imgY * width + imgX;
                    int filterIndex = filterY * filterSize + filterX;

                    suma += input[imgIndex] * d_filtro[filterIndex];
                }
            }
            
            int valorPixel = (int)suma;
            if (valorPixel > 255) valorPixel = 255;
            if (valorPixel < 0) valorPixel = 0;
            
            output[tid] = (unsigned char)valorPixel;
        }
    }
}

// --- KERNEL 2: Emboss (Relieve) Adaptado ---
// Trabaja con la imagen en escala de grises al igual que los otros kernels
__global__ void emboss_global(const unsigned char* input, unsigned char* output, int width, int height, int filterSize) {
    long long tid = threadIdx.x + blockIdx.x * blockDim.x;
    long long totalPixels = (long long)width * height;

    if (tid < totalPixels) {
        int x = tid % width;
        int y = tid / width;
        int half = filterSize / 2;
        float sum = 0.0f;

        // Bucle de convolución con bordes limitados (clamp)
        for (int ky = -half; ky <= half; ky++) {
            for (int kx = -half; kx <= half; kx++) {
                // Validación de límites para no salir de la imagen
                int sx = min(max(x + kx, 0), width - 1);
                int sy = min(max(y + ky, 0), height - 1);
                
                int imgIndex = sy * width + sx;
                int filterIndex = (ky + half) * filterSize + (kx + half);
                
                // Leemos el pixel (ya está en gris en nuestro sistema)
                float pixelVal = (float)input[imgIndex];
                
                sum += pixelVal * d_filtro[filterIndex];
            }
        }

        // Normalización específica para el Emboss
        float norm = (float)filterSize * 0.8f;
        // Se suma 128.5f para centrar el gris (típico en efectos de relieve)
        int finalPixel = min(max((int)(sum / norm + 128.5f), 0), 255);
        
        output[tid] = (unsigned char)finalPixel;
    }
}
"""

mod = SourceModule(codigo_kernel)
convolucionGPU_1D = mod.get_function("convolucionGPU_1D")
emboss_global = mod.get_function("emboss_global")
d_filtro_ptr, _ = mod.get_global("d_filtro")

# 2. Funciones generadoras de filtros
def generarFiltroMotionBlur(n):
    filtro = np.zeros((n, n), dtype=np.float32)
    valor = 1.0 / n
    np.fill_diagonal(filtro, valor)
    return filtro.flatten()

def generarFiltroNitidez(n):
    total = n * n
    if total <= 1:
        return np.array([2.0], dtype=np.float32)
    valExterior = -1.0 / float(total - 1)
    filtro = np.full((n, n), valExterior, dtype=np.float32)
    centro = n // 2
    filtro[centro, centro] = 2.0
    return filtro.flatten()

def generarFiltroEmboss(n):
    # Traducido de tu build_emboss_kernel en C++
    filtro = np.zeros((n, n), dtype=np.float32)
    half = n // 2
    for r in range(n):
        for c in range(n):
            filtro[r, c] = float((c - half) - (r - half))
    return filtro.flatten()

# 3. Endpoint principal
@app.post("/api/v1/process/{filter_name}")
async def process_image(
    filter_name: str, 
    filter_size: int = Query(65, description="Tamaño de la matriz del filtro"),
    file: UploadFile = File(...)
):
    try:
        # Validación de tamaño máximo del filtro (para no desbordar d_filtro de 15625)
        if filter_size > 125:
            raise HTTPException(status_code=400, detail="El tamaño máximo del filtro es 125.")

        contents = await file.read()
        nparr = np.frombuffer(contents, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_GRAYSCALE)

        if img is None:
            raise HTTPException(status_code=400, detail="Imagen no válida")

        height, width = img.shape
        imagen_plana = img.flatten().astype(np.uint8)
        imagenSalida_plana = np.zeros_like(imagen_plana)

        # Seleccionar y generar la matriz del filtro
        if filter_name == "motion_blur":
            filtroHost = generarFiltroMotionBlur(filter_size)
            kernel_func = convolucionGPU_1D
        elif filter_name == "nitidez":
            filtroHost = generarFiltroNitidez(filter_size)
            kernel_func = convolucionGPU_1D
        elif filter_name == "emboss":
            filtroHost = generarFiltroEmboss(filter_size)
            kernel_func = emboss_global
        else:
            raise HTTPException(status_code=404, detail="Filtro no reconocido. Usa 'motion_blur', 'nitidez' o 'emboss'.")

        cuda.memcpy_htod(d_filtro_ptr, filtroHost)

        # Configuración de hilos y bloques (Layout 1D)
        hilosPorBloque = 256
        totalPixeles = width * height
        bloquesPorGrid = (totalPixeles + hilosPorBloque - 1) // hilosPorBloque

        width_c = np.int32(width)
        height_c = np.int32(height)
        size_c = np.int32(filter_size)

        start = cuda.Event()
        stop = cuda.Event()

        start.record()
        # Ambos kernels reciben los mismos parámetros
        kernel_func(
            cuda.In(imagen_plana), 
            cuda.Out(imagenSalida_plana), 
            width_c, height_c, size_c,
            block=(hilosPorBloque, 1, 1), 
            grid=(bloquesPorGrid, 1)
        )
        stop.record()
        stop.synchronize()

        tiempo_ms = start.time_till(stop)

        imagenSalida = imagenSalida_plana.reshape((height, width))
        _, buffer = cv2.imencode('.jpg', imagenSalida)
        img_base64 = base64.b64encode(buffer).decode('utf-8')

        return {
            "estado": "Exito",
            "filtro_aplicado": filter_name,
            "tamaño_filtro_usado": f"{filter_size}x{filter_size}",
            "tamaño_imagen": f"{width}x{height}",
            "dimension_bloque": f"({hilosPorBloque}, 1, 1)",
            "dimension_grid": f"({bloquesPorGrid}, 1, 1)",
            "total_hilos": bloquesPorGrid * hilosPorBloque,
            "tiempo_ejecucion_ms": round(tiempo_ms, 2),
            "imagen_procesada_b64": img_base64
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))