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
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Usuário não encontrado'),
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Perfil'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await ref.read(authServiceProvider).signOut();
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user.photoURL != null
                      ? NetworkImage(user.photoURL!)
                      : null,
                  child: user.photoURL == null
                      ? const Icon(Icons.person, size: 80)
                      : null,
                ),
                const SizedBox(height: 16),
                if (user.displayName != null) ...[
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text(
                      'Nome',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(user.displayName!),
                  ),
                ],
                if (user.email != null) ...[
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text(
                      'Email',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(user.email!),
                  ),
                ],
                if (user.phoneNumber != null) ...[
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text(
                      'Telefone',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(user.phoneNumber!),
                  ),
                ],
                ListTile(
                  leading: Icon(
                    user.emailVerified ? Icons.verified : Icons.warning,
                    color: user.emailVerified ? Colors.green : Colors.orange,
                  ),
                  title: const Text(
                    'Status do Email',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(user.emailVerified
                      ? 'Email verificado'
                      : 'Email não verificado'),
                  trailing: !user.emailVerified
                      ? TextButton(
                          onPressed: () async {
                            try {
                              await user.sendEmailVerification();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Email de verificação enviado!'),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Erro ao enviar email de verificação'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: const Text('Verificar'),
                        )
                      : null,
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text(
                    'Conta criada em',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(user.metadata.creationTime?.toString() ??
                      'Data desconhecida'),
                ),
              ],
            ),
          ),
        ));
  }
}
