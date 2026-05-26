import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _usernameCtrl;
  bool _loading = false;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    final current = ref.read(authProvider).username ?? '';
    _usernameCtrl = TextEditingController(text: current)
      ..addListener(() => setState(() => _changed = true));
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final username = _usernameCtrl.text.trim();
    if (username.isEmpty) {
      _showError('El nombre de usuario no puede estar vacío');
      return;
    }
    if (username.length < 3) {
      _showError('El nombre de usuario debe tener al menos 3 caracteres');
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).updateProfile(username: username);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = ref.watch(authProvider.select((s) => s.username)) ?? '';
    final initial  = username.isNotEmpty ? username[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Editar perfil',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          _loading
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: AppTheme.navy),
                  ),
                )
              : TextButton(
                  onPressed: _changed ? _save : null,
                  child: Text(
                    'Guardar',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: _changed ? AppTheme.navy : AppTheme.textSecondary,
                    ),
                  ),
                ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppTheme.inputBorder),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // ── Avatar ──────────────────────────────────
                Center(
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.upsGradient,
                        ),
                        child: CircleAvatar(
                          radius: 48,
                          backgroundColor: AppTheme.background,
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.navy,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Campos ──────────────────────────────────
                _FieldSection(
                  label: 'Nombre de usuario',
                  child: TextField(
                    controller: _usernameCtrl,
                    enabled: !_loading,
                    decoration: InputDecoration(
                      hintText: 'Ej: juan_ups',
                      prefixIcon: const Icon(Icons.alternate_email),
                      suffixIcon: _usernameCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  size: 18, color: AppTheme.textSecondary),
                              onPressed: () {
                                _usernameCtrl.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Botón guardar ────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_loading || !_changed) ? null : _save,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text('Guardar cambios'),
                  ),
                ),
              ],
            ),
          ),

          // ── Overlay de carga ─────────────────────────────
          if (_loading)
            Container(
              color: Colors.white.withValues(alpha: 0.6),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppTheme.navy),
                    SizedBox(height: 16),
                    Text('Guardando...',
                        style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FieldSection extends StatelessWidget {
  final String label;
  final Widget child;
  const _FieldSection({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
