import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _ctrl    = TextEditingController();
  bool _loading  = false;
  bool _sent     = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final identifier = _ctrl.text.trim();
    if (identifier.isEmpty) {
      _showError('Ingresa tu usuario o correo');
      return;
    }
    setState(() => _loading = true);
    try {
      await ApiService().forgotPassword(identifier);
      if (!mounted) return;
      setState(() { _loading = false; _sent = true; });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      final msg = e.toString().replaceAll('Exception: ', '');
      _showError(msg.contains('no encontrado')
          ? 'No existe ninguna cuenta con ese usuario o correo'
          : msg);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Recuperar contraseña',
            style: TextStyle(fontWeight: FontWeight.w800)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppTheme.inputBorder),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _sent ? _SuccessView(identifier: _ctrl.text.trim()) : _FormView(
          ctrl: _ctrl,
          loading: _loading,
          onSend: _send,
        ),
      ),
    );
  }
}

// ── Formulario ────────────────────────────────────────
class _FormView extends StatelessWidget {
  final TextEditingController ctrl;
  final bool loading;
  final VoidCallback onSend;
  const _FormView({required this.ctrl, required this.loading, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.upsGradient,
          ),
          child: const Icon(Icons.lock_reset, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 20),
        const Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 6),
        const Text(
          'Ingresa tu usuario o correo y te enviaremos un enlace para restablecerla.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 28),
        TextField(
          controller: ctrl,
          autocorrect: false,
          keyboardType: TextInputType.text,
          onSubmitted: (_) => onSend(),
          decoration: const InputDecoration(
            labelText: 'Usuario o correo',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: loading ? null : onSend,
          child: loading
              ? const SizedBox(
                  height: 20, width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : const Text('Enviar enlace de recuperación'),
        ),
      ],
    );
  }
}

// ── Confirmación ──────────────────────────────────────
class _SuccessView extends StatelessWidget {
  final String identifier;
  const _SuccessView({required this.identifier});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green.shade50,
            border: Border.all(color: Colors.green, width: 2),
          ),
          child: Icon(Icons.mark_email_read_outlined,
              color: Colors.green.shade600, size: 40),
        ),
        const SizedBox(height: 20),
        const Text(
          'Correo enviado',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 10),
        Text(
          'Revisá tu bandeja de entrada. Haz clic en el enlace del correo para restablecer tu contraseña.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 32),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            side: const BorderSide(color: AppTheme.navy),
            foregroundColor: AppTheme.navy,
          ),
          child: const Text('Volver al inicio de sesión',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
