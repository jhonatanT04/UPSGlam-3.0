# UPSGlam 3.0

## implementación en proceso........

Backend Reactivo (Spring WebFlux): Funciona como orquestador, coordinando la comunicación entre los diferentes servicios.

Servicio GPU (FastAPI + PyCUDA): Microservicio en Python que ejecuta los kernels de convolución en la tarjeta de video.

Supabase Storage: Sube automáticamente las imágenes procesadas y genera URLs públicas para su visualización.

Persistencia de Datos (REST API): El backend guarda exitosamente las métricas de la GPU (tiempo de ejecución, hilos, bloques, etc.) en PostgreSQL mediante la API REST de Supabase, lo que evita cualquier bloqueo de puertos en redes universitarias o locales.


## Requisitos (Dependencias)

Antes de ejecutar, asegúrense de tener instalado en su entorno Linux (Ubuntu/Kubuntu):

    Java 21 y Maven (Para el backend en Spring Boot).

    Python 3.x y pip (Para el servicio de GPU).

    NVIDIA Drivers y CUDA Toolkit instalados y configurados en sus variables de entorno (Indispensable para compilar PyCUDA).

## Configuración del Entorno de Variables

Deben crear un archivo llamado .env en la raíz del proyecto (fuera de las carpetas backend-webflux y gpu-service)

### Ejecutar el Servicio GPU (Python)

cd UPSGlam-3.0/gpu-service:

Crear el entorno virtual (solo la primera vez):
python3 -m venv venv

Activar el entorno virtual:
source venv/bin/activate

Instalar dependencias necesarias:
pip install -r requirements.txt

Iniciar el servidor:
uvicorn main:app --reload 

# Ejecutar el Backend (Spring WebFlux)

cd UPSGlam-3.0/backend-webflux

Limpiar y empaquetar el proyecto (compilar):
mvn clean package -DskipTests

Cargar las variables de entorno del archivo .env :
set -a; source ../.env; set +a;

 Levantar el servidor de Spring Boot :
java -jar target/upsglam-backend-0.0.1-SNAPSHOT.jar

# Prueba con imagen

#Con ambas terminales corriendo, abran una tercera terminal para probar el flujo completo enviando una imagen.

cambiar la ruta de la imagen en @/ruta/a/tu/imagen.jpg por una imagen real que tengan en su PC.
ejemplo:

curl -X POST "http://localhost:"puerto"/api/v1/images/process/motion_blur?filter_size=125" \
  -F "file=@/ruta/a/tu/imagen.jpg"