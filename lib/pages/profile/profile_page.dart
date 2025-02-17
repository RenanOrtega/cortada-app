import 'package:cortada_app/providers/api_provider.dart';
import 'package:cortada_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentUserProvider = Provider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentUser;
});

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final authMethodsAsync = ref.watch(authMethodsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: userProfileAsync.when(
        data: (profile) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nome: ${profile['displayName'] ?? 'Não informado'}'),
              Text('Email: ${profile['email'] ?? 'Não informado'}'),
              Text('Telefone: ${profile['phoneNumber'] ?? 'Não informado'}'),
              const SizedBox(height: 24),
              authMethodsAsync.when(
                data: (methods) => Column(
                  children: methods
                      .map((method) => ListTile(
                            title: Text(_getMethodName(method)),
                            leading: _getMethodIcon(method),
                          ))
                      .toList(),
                ),
                error: (error, stack) => Text('Erro: $error'),
                loading: () => const CircularProgressIndicator(),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Erro ao carregar perfil: $error'),
        ),
      ),
    );
  }

  String _getMethodName(String method) {
    switch (method) {
      case 'google.com':
        return 'Google';
      case 'apple.com':
        return 'Apple';
      case 'phone':
        return 'Telefone';
      default:
        return method;
    }
  }

  Icon _getMethodIcon(String method) {
    switch (method) {
      case 'google.com':
        return const Icon(Icons.g_mobiledata);
      case 'apple.com':
        return const Icon(Icons.apple);
      case 'phone':
        return const Icon(Icons.phone);
      default:
        return const Icon(Icons.login);
    }
  }
}
