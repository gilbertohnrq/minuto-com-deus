import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/local_user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/main_navigation.dart';
import '../../../core/utils/date_utils.dart' as app_date_utils;

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentLocalUserProvider);
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return MainNavigation(
      currentRoute: '/settings',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Configurações'),
          backgroundColor: theme.colorScheme.inversePrimary,
          elevation: 0,
        ),
        body: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 600 : double.infinity,
          ),
          margin: isTablet ? const EdgeInsets.symmetric(horizontal: 40) : EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Section
              _buildUserProfileSection(context, currentUser, theme, isTablet),
              
              const SizedBox(height: 24),
              
              // Notification Settings Section
              _buildNotificationSection(context, currentUser, theme, isTablet),
              
              const SizedBox(height: 24),
              
              // Theme Settings Section
              _buildThemeSection(context, ref, theme, isTablet),
              
              const SizedBox(height: 24),
              
              // Premium Status Section
              _buildPremiumSection(context, currentUser, theme, isTablet),
              
              const SizedBox(height: 32),
              
              // Reset Data Section (replace logout in freemium model)
              _buildResetDataSection(context, ref, theme, isTablet),
              
              const SizedBox(height: 24),
              
              // App Info Section
              _buildAppInfoSection(context, theme, isTablet),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildUserProfileSection(BuildContext context, user, ThemeData theme, bool isTablet) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: isTablet ? 32 : 24,
                  backgroundColor: theme.colorScheme.primary,
                  child: Icon(
                    Icons.person,
                    size: isTablet ? 32 : 24,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Usuário Anônimo',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 24 : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.isActivePremium == true ? 'Usuário Premium' : 'Usuário Gratuito',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: user?.isActivePremium == true 
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          fontSize: isTablet ? 16 : null,
                          fontWeight: user?.isActivePremium == true 
                              ? FontWeight.w600 
                              : FontWeight.normal,
                        ),
                      ),
                      if (user?.createdAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Membro desde ${app_date_utils.DateUtils.formatDateDisplay(user!.createdAt)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            fontSize: isTablet ? 14 : null,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection(BuildContext context, user, ThemeData theme, bool isTablet) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications,
                  color: theme.colorScheme.primary,
                  size: isTablet ? 28 : 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Notificações',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 20 : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Notification enabled toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notificações diárias',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: isTablet ? 18 : null,
                        ),
                      ),
                      Text(
                        'Receba lembretes para ler o devocional',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          fontSize: isTablet ? 14 : null,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: user?.notificationSettings.enabled ?? true,
                  onChanged: (value) {
                    // TODO: Implement notification settings update
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Configuração de notificações em breve'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Notification time setting
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.schedule,
                color: theme.colorScheme.primary,
              ),
              title: Text(
                'Horário das notificações',
                style: TextStyle(
                  fontSize: isTablet ? 18 : null,
                ),
              ),
              subtitle: Text(
                '08:00', // TODO: Get from user settings
                style: TextStyle(
                  fontSize: isTablet ? 14 : null,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Implement time picker
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Configuração de horário em breve'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context, WidgetRef ref, ThemeData theme, bool isTablet) {
    final currentTheme = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette,
                  color: theme.colorScheme.primary,
                  size: isTablet ? 28 : 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Aparência',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 20 : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Theme detection info
            Container(
              padding: EdgeInsets.all(isTablet ? 16.0 : 12.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: isTablet ? 20 : 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'O tema foi detectado automaticamente baseado nas configurações do seu dispositivo',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        fontSize: isTablet ? 14 : 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Theme mode selection
            Column(
              children: AppThemeMode.values.map((mode) {
                return RadioListTile<AppThemeMode>(
                  title: Text(
                    _getThemeModeTitle(mode),
                    style: TextStyle(
                      fontSize: isTablet ? 16 : null,
                    ),
                  ),
                  subtitle: Text(
                    _getThemeModeSubtitle(mode),
                    style: TextStyle(
                      fontSize: isTablet ? 14 : null,
                    ),
                  ),
                  value: mode,
                  groupValue: currentTheme,
                  onChanged: (AppThemeMode? value) {
                    if (value != null) {
                      themeNotifier.setTheme(value);
                    }
                  },
                  contentPadding: EdgeInsets.zero,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getThemeModeTitle(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Claro';
      case AppThemeMode.dark:
        return 'Escuro';
      case AppThemeMode.system:
        return 'Sistema';
    }
  }
  
  String _getThemeModeSubtitle(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Sempre use tema claro';
      case AppThemeMode.dark:
        return 'Sempre use tema escuro';
      case AppThemeMode.system:
        return 'Seguir configuração do sistema';
    }
  }

  Widget _buildPremiumSection(BuildContext context, user, ThemeData theme, bool isTablet) {
    final isPremium = user?.isActivePremium ?? false;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isPremium ? Icons.star : Icons.star_border,
                  color: isPremium ? Colors.amber : theme.colorScheme.primary,
                  size: isTablet ? 28 : 24,
                ),
                const SizedBox(width: 12),
                Text(
                  isPremium ? 'Premium' : 'Versão Gratuita',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 20 : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isPremium 
                ? 'Você tem acesso completo a todos os recursos premium!'
                : 'Faça upgrade para Premium e tenha acesso a recursos exclusivos',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: isTablet ? 16 : null,
              ),
            ),
            if (!isPremium) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/premium');
                  },
                  icon: const Icon(Icons.upgrade),
                  label: Text(
                    'Fazer Upgrade',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : null,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 16 : 12,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResetDataSection(BuildContext context, WidgetRef ref, ThemeData theme, bool isTablet) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.refresh,
                  color: theme.colorScheme.error,
                  size: isTablet ? 28 : 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Resetar dados',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 20 : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Apagar todos os dados locais e começar do zero',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: isTablet ? 16 : null,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showResetDataConfirmation(context, ref),
                icon: const Icon(Icons.refresh),
                label: Text(
                  'Resetar dados',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : null,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(color: theme.colorScheme.error),
                  padding: EdgeInsets.symmetric(
                    vertical: isTablet ? 16 : 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoSection(BuildContext context, ThemeData theme, bool isTablet) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                  size: isTablet ? 28 : 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Sobre o App',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 20 : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Devocional Diário v1.0.0',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: isTablet ? 16 : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sua dose diária de inspiração e reflexão espiritual',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: isTablet ? 14 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDataConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Resetar dados'),
          content: const Text(
            'Tem certeza que deseja resetar todos os dados? '
            'Esta ação não pode ser desfeita e você perderá todas as configurações e preferências.',
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
                ref.read(currentLocalUserProvider.notifier).resetUserData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Dados resetados com sucesso'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Resetar'),
            ),
          ],
        );
      },
    );
  }
}