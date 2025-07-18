import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/subscription_service.dart';
import '../../providers/local_user_provider.dart';
import '../../widgets/common/loading_widget.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _purchaseSubscription(String planId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await SubscriptionService.instance.purchaseSubscription(planId);
      
      if (result.success && result.plan != null) {
        // Update local user premium status
        await ref.read(currentLocalUserProvider.notifier)
            .upgradeToPremium(expirationDate: result.expirationDate);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Parabéns! Você agora tem acesso Premium!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(); // Return to previous screen
        }
      } else {
        setState(() {
          _errorMessage = result.error ?? 'Erro desconhecido';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao processar pagamento: ${e.toString()}';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentLocalUserProvider);
    final isPremium = user?.isActivePremium ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium'),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isPremium) ...[
                    _buildPremiumStatusCard(context, user!),
                    const SizedBox(height: 24),
                  ],
                  
                  if (!isPremium) ...[
                    _buildHeaderSection(context),
                    const SizedBox(height: 24),
                    
                    _buildFeaturesList(context),
                    const SizedBox(height: 24),
                    
                    _buildSubscriptionPlans(context),
                    
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Card(
                        color: theme.colorScheme.errorContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildPremiumStatusCard(BuildContext context, user) {
    final theme = Theme.of(context);
    final trialDays = ref.read(currentLocalUserProvider.notifier).getTrialDaysRemaining();
    
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.star,
              size: 48,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(height: 8),
            Text(
              'Você é Premium!',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (trialDays != null && trialDays > 0)
              Text(
                'Restam $trialDays dias',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              )
            else if (user.premiumExpirationDate == null)
              Text(
                'Acesso vitalício',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Icon(
          Icons.workspace_premium,
          size: 64,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Desbloqueie o Premium',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Tenha acesso completo a todos os recursos do app',
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    final theme = Theme.of(context);
    
    final features = [
      'Sem anúncios',
      'Acesso a devocionais exclusivos',
      'Histórico completo de leituras',
      'Função de favoritos ilimitada',
      'Backup automático na nuvem',
      'Suporte prioritário',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'O que você ganha com Premium:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(feature),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionPlans(BuildContext context) {
    final theme = Theme.of(context);
    final plans = SubscriptionService.availablePlans.values.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Escolha seu plano:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...plans.map(
          (plan) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => _purchaseSubscription(plan.id),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            plan.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      plan.price,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
