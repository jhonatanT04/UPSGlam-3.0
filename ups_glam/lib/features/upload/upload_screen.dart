import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import 'upload_provider.dart';
import 'result_screen.dart';

const _filters = [
  ('motion_blur', 'Motion Blur', Icons.blur_on_outlined),
  ('nitidez',    'Nitidez',     Icons.center_focus_strong_outlined),
  ('emboss',     'Emboss',      Icons.texture_outlined),
];

class UploadScreen extends ConsumerWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(uploadProvider);
    final notifier = ref.read(uploadProvider.notifier);

    ref.listen<UploadState>(uploadProvider, (prev, next) {
      if (next.step == UploadStep.done && next.result != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ResultScreen(result: next.result!)),
        ).then((_) => notifier.reset());
      } else if (next.step == UploadStep.error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.errorMessage ?? 'Error al procesar'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ));
        notifier.reset();
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Nueva publicación'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppTheme.inputBorder),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Selector de imagen ───────────────────────
            _ImagePickerWidget(
              image: state.selectedImage,
              onPick: notifier.setImage,
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Filtros ─────────────────────────────
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: 18,
                        decoration: BoxDecoration(
                          gradient: AppTheme.upsGradient,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Filtro GPU',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppTheme.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _FilterSelector(
                      selected: state.selectedFilter,
                      onSelect: notifier.setFilter),

                  const SizedBox(height: 20),

                  // ── Tamaño del filtro ────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Container(
                          width: 3,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppTheme.gold,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Tamaño del filtro',
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15)),
                      ]),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.navy.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${state.filterSize}px',
                          style: const TextStyle(
                              color: AppTheme.navy,
                              fontWeight: FontWeight.w700,
                              fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppTheme.navy,
                      inactiveTrackColor:
                          AppTheme.navy.withValues(alpha: 0.15),
                      thumbColor: AppTheme.navy,
                      overlayColor: AppTheme.navy.withValues(alpha: 0.12),
                    ),
                    child: Slider(
                      value: state.filterSize.toDouble(),
                      min: 3,
                      max: 125,
                      divisions: 61,
                      onChanged: (v) => notifier.setFilterSize(v.toInt()),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Botón procesar ───────────────────────
                  _ProcessButton(state: state, onPress: notifier.processImage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePickerWidget extends StatelessWidget {
  final File? image;
  final ValueChanged<File> onPick;
  const _ImagePickerWidget({required this.image, required this.onPick});

  Future<void> _pick(BuildContext context) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              decoration: BoxDecoration(
                  color: AppTheme.inputBorder,
                  borderRadius: BorderRadius.circular(2)),
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.upsGradient),
                child: const Icon(Icons.photo_library,
                    color: AppTheme.gold, size: 20),
              ),
              title: const Text('Galería',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.navy.withValues(alpha: 0.08)),
                child: const Icon(Icons.camera_alt_outlined,
                    color: AppTheme.navy, size: 20),
              ),
              title: const Text('Cámara',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked =
        await picker.pickImage(source: source, imageQuality: 90);
    if (picked != null) onPick(File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pick(context),
      child: image == null
          ? Container(
              height: 280,
              color: AppTheme.background,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.upsGradient),
                    child: const Icon(Icons.add_photo_alternate_outlined,
                        size: 34, color: AppTheme.gold),
                  ),
                  const SizedBox(height: 14),
                  const Text('Seleccionar imagen',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppTheme.navy)),
                  const SizedBox(height: 4),
                  const Text('Galería o cámara',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
            )
          : Stack(
              children: [
                Image.file(image!,
                    height: 280,
                    width: double.infinity,
                    fit: BoxFit.cover),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _pick(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.navy),
                      child: const Icon(Icons.edit,
                          color: AppTheme.gold, size: 16),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _FilterSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _FilterSelector(
      {required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _filters
          .map((f) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => onSelect(f.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: selected == f.$1
                            ? AppTheme.upsGradient
                            : null,
                        color: selected == f.$1
                            ? null
                            : AppTheme.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected == f.$1
                              ? AppTheme.gold
                              : AppTheme.inputBorder,
                          width: selected == f.$1 ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(f.$3,
                              color: selected == f.$1
                                  ? AppTheme.gold
                                  : AppTheme.textSecondary,
                              size: 22),
                          const SizedBox(height: 5),
                          Text(f.$2,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: selected == f.$1
                                    ? AppTheme.white
                                    : AppTheme.textSecondary,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _ProcessButton extends StatelessWidget {
  final UploadState state;
  final VoidCallback onPress;
  const _ProcessButton({required this.state, required this.onPress});

  @override
  Widget build(BuildContext context) {
    final enabled = state.selectedImage != null &&
        state.step != UploadStep.processing;
    return Container(
      decoration: BoxDecoration(
        gradient: enabled ? AppTheme.upsGradient : null,
        color: enabled ? null : AppTheme.inputBorder,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: enabled ? onPress : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state.step == UploadStep.processing)
                  const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: AppTheme.gold, strokeWidth: 2))
                else
                  const Icon(Icons.memory, color: AppTheme.gold, size: 20),
                const SizedBox(width: 10),
                Text(
                  state.step == UploadStep.processing
                      ? 'Procesando en GPU...'
                      : 'Procesar imagen',
                  style: TextStyle(
                    color: enabled
                        ? AppTheme.white
                        : AppTheme.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
