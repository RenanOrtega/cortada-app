import 'package:cortada_app/providers/api_provider.dart';
import 'package:cortada_app/providers/auth_provider.dart';
import 'package:cortada_app/router/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController phoneController = TextEditingController();
  String? _verificationId;
  bool _isLoading = false;

  Future<void> _updateUserProfile() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      // await apiService.updateUserProfile();
    } catch (e) {
      if (!context.mounted) return;
      _showErrorSnackBar('Erro ao atualizar perfil: ${e.toString()}');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final UserCredential? userCredential =
          await authService.signInWithGoogle();

      if (!context.mounted) return;

      if (userCredential != null) {
        // await _updateUserProfile();
        context.go(AppRoutes.onboarding);
      }
    } catch (e) {
      if (!context.mounted) return;
      _showErrorSnackBar('Erro ao fazer login: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _handleAppleSignIn() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final UserCredential? userCredential =
          await authService.signInWithApple();

      if (!context.mounted) return;

      if (userCredential != null) {
        await _updateUserProfile();
        context.go(AppRoutes.onboarding);
      }
    } catch (e) {
      if (!context.mounted) return;
      _showErrorSnackBar('Erro ao fazer login: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePhoneSignIn() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      _verificationId = await authService.verifyPhoneNumber(
        phoneController.text,
      );

      if (!context.mounted) return;

      // Aqui você pode abrir um dialog para o código SMS
      // e chamar _handleSMSVerification com o código
    } catch (e) {
      if (!context.mounted) return;
      _showErrorSnackBar('Erro ao verificar número: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSMSVerification(String smsCode) async {
    if (_verificationId == null || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final userCredential = await authService.verifySMSCode(
        smsCode: smsCode,
        verificationId: _verificationId!,
      );

      if (!context.mounted) return;

      if (userCredential != null) {
        await _updateUserProfile();
        context.go(AppRoutes.onboarding);
      }
    } catch (e) {
      if (!context.mounted) return;
      _showErrorSnackBar('Erro ao verificar código: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 48.0),
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 120,
                  width: 120,
                ),
              ),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Digite seu número de celular',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _handlePhoneSignIn(),
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.blue),
                    child: const Text(
                      'Entrar',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Text(
                  'Ou continue com',
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => _handleGoogleSignIn(),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        )),
                    child: Image.asset(
                      'assets/images/google_icon.png',
                      height: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: () => _handleAppleSignIn(),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        )),
                    child: const Icon(
                      Icons.apple,
                      size: 20,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
