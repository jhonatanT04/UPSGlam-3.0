import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  static const route = '/register';

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final emailCtrl    = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool obscure = true;
  bool loading = false;
  String _password = '';

  @override
  void initState() {
    super.initState();
    passwordCtrl.addListener(() => setState(() => _password = passwordCtrl.text));
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final email    = emailCtrl.text.trim();
    final password = passwordCtrl.text;
    if (email.isEmpty || password.isEmpty) {
      _showError('Completa todos los campos');
      return;
    }
    if (password.length < 6) {
      _showError('La contraseña debe tener al menos 6 caracteres');
      return;
    }
    setState(() => loading = true);
    try {
      await ref.read(authProvider.notifier).register(email, password);
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => loading = false);
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
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Crear cuenta'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 0.5, color: AppTheme.inputBorder),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'UPSGlam',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppTheme.navy,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text('Únete a UPSGlam',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            const Text('Comparte tus imágenes procesadas con GPU',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 28),

            // ── Email ──────────────────────────────────────
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo institucional',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 14),

            // ── Contraseña + indicador de fortaleza ────────
            TextField(
              controller: passwordCtrl,
              obscureText: obscure,
              onSubmitted: (_) => _register(),
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => obscure = !obscure),
                  icon: Icon(obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined),
                ),
              ),
            ),
            if (_password.isNotEmpty) ...[
              const SizedBox(height: 8),
              _PasswordStrengthBar(password: _password),
            ],
            const SizedBox(height: 28),

            ElevatedButton(
              onPressed: loading ? null : _register,
              child: loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : const Text('Registrarse'),
            ),
            const SizedBox(height: 16),

            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 14),
                    children: [
                      TextSpan(
                          text: '¿Ya tienes cuenta? ',
                          style: TextStyle(color: AppTheme.textSecondary)),
                      TextSpan(
                          text: 'Inicia sesión',
                          style: TextStyle(
                              color: AppTheme.navy,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Indicador de fortaleza ─────────────────────────────
class _PasswordStrengthBar extends StatelessWidget {
  final String password;
  const _PasswordStrengthBar({required this.password});

  static _StrengthLevel _evaluate(String p) {
    if (p.length < 6) return _StrengthLevel.weak;
    int score = 0;
    if (p.length >= 8)  score++;
    if (p.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(p)) score++;
    if (RegExp(r'[0-9]').hasMatch(p)) score++;
    if (RegExp(r'[!@#\$%^&*()_+\-=\[\]{}|;:,.<>?/]').hasMatch(p)) score++;
    if (score <= 1) return _StrengthLevel.weak;
    if (score <= 3) return _StrengthLevel.medium;
    return _StrengthLevel.strong;
  }

  @override
  Widget build(BuildContext context) {
    final level = _evaluate(password);
    final (color, label, filled) = switch (level) {
      _StrengthLevel.weak   => (Colors.red.shade600,    'Contraseña débil — usa más de 8 caracteres, números y mayúsculas', 1),
      _StrengthLevel.medium => (Colors.orange.shade600, 'Contraseña aceptable — agrega símbolos para mejorarla', 2),
      _StrengthLevel.strong => (Colors.green.shade600,  'Contraseña fuerte', 3),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(3, (i) => Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 4,
              margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
              decoration: BoxDecoration(
                color: i < filled ? color : AppTheme.inputBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          )),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Icon(_iconFor(level), size: 13, color: color),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 11.5, color: color, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _iconFor(_StrengthLevel l) => switch (l) {
    _StrengthLevel.weak   => Icons.warning_amber_rounded,
    _StrengthLevel.medium => Icons.info_outline,
    _StrengthLevel.strong => Icons.check_circle_outline,
  };
}

enum _StrengthLevel { weak, medium, strong }
