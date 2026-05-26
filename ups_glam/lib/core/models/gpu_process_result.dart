class GpuProcessResult {
  final String estado;
  final String filtroAplicado;
  final String tamanoFiltroUsado;
  final String tamanoImagen;
  final String dimensionBloque;
  final String dimensionGrid;
  final int totalHilos;
  final double tiempoEjecucionMs;
  final String urlImagenProcesada;

  const GpuProcessResult({
    required this.estado,
    required this.filtroAplicado,
    required this.tamanoFiltroUsado,
    required this.tamanoImagen,
    required this.dimensionBloque,
    required this.dimensionGrid,
    required this.totalHilos,
    required this.tiempoEjecucionMs,
    required this.urlImagenProcesada,
  });

  factory GpuProcessResult.fromJson(Map<String, dynamic> j) => GpuProcessResult(
        estado: j['estado'] as String,
        filtroAplicado: j['filtro_aplicado'] as String? ?? '',
        tamanoFiltroUsado: j['tamaño_filtro_usado'] as String? ?? '',
        tamanoImagen: j['tamaño_imagen'] as String? ?? '',
        dimensionBloque: j['dimension_bloque'] as String? ?? '',
        dimensionGrid: j['dimension_grid'] as String? ?? '',
        totalHilos: (j['total_hilos'] as num?)?.toInt() ?? 0,
        tiempoEjecucionMs: (j['tiempo_ejecucion_ms'] as num?)?.toDouble() ?? 0.0,
        urlImagenProcesada: j['url_imagen_procesada'] as String? ?? '',
      );
}
