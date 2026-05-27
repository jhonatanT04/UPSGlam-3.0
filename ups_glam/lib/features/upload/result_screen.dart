import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/gpu_process_result.dart';
import '../../core/theme/app_theme.dart';
import '../feed/feed_provider.dart';
import '../home/home_screen.dart';
import '../profile/profile_provider.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final GpuProcessResult result;
  const ResultScreen({super.key, required this.result});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  final _captionCtrl = TextEditingController();
  bool _publishing = false;
  bool _metricsExpanded = false;

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    setState(() => _publishing = true);
    try {
      final post = await ref.read(apiServiceProvider).createPost(
            imageUrl: widget.result.urlImagenProcesada,
            caption: _captionCtrl.text.trim().isEmpty
                ? null
                : _captionCtrl.text.trim(),
          );
      await ref.read(feedProvider.notifier).addNewPost(post);
      ref.invalidate(myProfileProvider);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      ref.read(homeTabProvider.notifier).state = 0;
      messenger.showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('¡Publicación exitosa!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() => _publishing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al publicar: $e'),
            backgroundColor: AppTheme.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        flexibleSpace: Container(
            decoration:
                const BoxDecoration(gradient: AppTheme.upsGradient)),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                r.urlImagenProcesada,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : SizedBox(
                        height: 300,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 8),
                              Text(
                                'Cargando imagen procesada...',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                errorBuilder: (context, e, s) => Container(
                  height: 300,
                  color: AppTheme.surface,
                  child: const Icon(Icons.broken_image_outlined,
                      size: 56, color: AppTheme.textSecondary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _MetricsCard(result: r, expanded: _metricsExpanded,
                onToggle: () =>
                    setState(() => _metricsExpanded = !_metricsExpanded)),
            const SizedBox(height: 16),
            TextField(
              controller: _captionCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Escribe un comentario (opcional)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _publishing ? null : _publish,
              icon: _publishing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.publish),
              label:
                  Text(_publishing ? 'Publicando...' : 'Publicar en el feed'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricsCard extends StatelessWidget {
  final GpuProcessResult result;
  final bool expanded;
  final VoidCallback onToggle;

  const _MetricsCard(
      {required this.result,
      required this.expanded,
      required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final r = result;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.memory, color: AppTheme.primary),
            title: const Text('Métricas GPU',
                style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(
                '${r.filtroAplicado} · ${r.tiempoEjecucionMs.toStringAsFixed(2)} ms'),
            trailing: IconButton(
              icon: Icon(
                  expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: onToggle,
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(1.4),
                  1: FlexColumnWidth(1),
                },
                children: [
                  _row('Filtro', r.filtroAplicado),
                  _row('Tamaño filtro', r.tamanoFiltroUsado),
                  _row('Imagen', r.tamanoImagen),
                  _row('Bloque', r.dimensionBloque),
                  _row('Grid', r.dimensionGrid),
                  _row('Total hilos', '${r.totalHilos}'),
                  _row('Tiempo', '${r.tiempoEjecucionMs.toStringAsFixed(2)} ms'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  TableRow _row(String label, String value) => TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Text(label,
                style: const TextStyle(color: AppTheme.textSecondary)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      );
}
