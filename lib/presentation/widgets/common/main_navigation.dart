import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';

class MainNavigation extends ConsumerWidget {
  final Widget child;
  final String currentRoute;

  const MainNavigation({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            currentUser.when(
              data: (user) => UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                ),
                accountName: Text(
                  user?.name ?? 'Usuário',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(
                  user?.email ?? '',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: theme.colorScheme.onPrimary,
                  child: Icon(
                    Icons.person,
                    color: theme.colorScheme.primary,
                    size: 32,
                  ),
                ),
              ),
              loading: () => UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                ),
                accountName: Text(
                  'Carregando...',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: const Text(''),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: theme.colorScheme.onPrimary,
                  child: Icon(
                    Icons.person,
                    color: theme.colorScheme.primary,
                    size: 32,
                  ),
                ),
              ),
              error: (_, __) => UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                ),
                accountName: Text(
                  'Usuário',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: const Text(''),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: theme.colorScheme.onPrimary,
                  child: Icon(
                    Icons.person,
                    color: theme.colorScheme.primary,
                    size: 32,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Início'),
              selected: currentRoute == '/home',
              onTap: () {
                Navigator.pop(context);
                if (currentRoute != '/home') {
                  Navigator.pushReplacementNamed(context, '/home');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurações'),
              selected: currentRoute == '/settings',
              onTap: () {
                Navigator.pop(context);
                if (currentRoute != '/settings') {
                  Navigator.pushReplacementNamed(context, '/settings');
                }
              },
            ),
            const Divider(),
            if (currentUser.when(
              data: (user) => user?.isPremium == true,
              loading: () => false,
              error: (_, __) => false,
            ))
              ListTile(
                leading: Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                title: const Text('Premium'),
                subtitle: const Text('Conta Premium ativa'),
                onTap: () {
                  Navigator.pop(context);
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.upgrade),
                title: const Text('Fazer Upgrade'),
                subtitle: const Text('Acesse recursos premium'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Upgrade Premium em breve'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: theme.colorScheme.error,
              ),
              title: Text(
                'Sair',
                style: TextStyle(
                  color: theme.colorScheme.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showLogoutConfirmation(context, ref);
              },
            ),
          ],
        ),
      ),
      body: child,
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar saída'),
          content: const Text(
            'Tem certeza de que deseja sair da sua conta? '
            'Você precisará fazer login novamente para acessar o app.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(authNotifierProvider.notifier).signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }
}
