import 'package:cortada_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class VerificationCodeDialog extends StatefulWidget {
  final String verificationId;
  final AuthService authService;

  const VerificationCodeDialog({
    super.key,
    required this.verificationId,
    required this.authService,
  });

  @override
  State<VerificationCodeDialog> createState() => _VerificationCodeDialogState();
}

class _VerificationCodeDialogState extends State<VerificationCodeDialog> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código inválido')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await widget.authService.verifySMSCode(
        smsCode: _codeController.text,
        verificationId: widget.verificationId,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Verificação'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Digite o código de 6 digitos enviado para seu telefone.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              hintText: 'Código SMS',
              counterText: '',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _verifyCode,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('Verificar'),
        ),
      ],
    );
  }
}
