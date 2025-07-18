import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_snackbar.dart';
import '../../../core/utils/validators.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleEmailLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = Validators.sanitizeInput(_emailController.text);
      final password = _passwordController.text;
      
      await ref.read(authNotifierProvider.notifier).signInWithEmail(email, password);
    }
  }

  void _handleGoogleLogin() async {
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
  }

  void _navigateToRegister() {
    Navigator.of(context).pushNamed('/register');
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => _ForgotPasswordDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    
    // Clear error when widget rebuilds
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.errorMessage != null) {
        CustomSnackBar.showError(
          context: context,
          message: next.errorMessage!,
          actionLabel: 'OK',
          onAction: () {
            ref.read(authNotifierProvider.notifier).clearError();
          },
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                
                // App Logo/Icon
                const Icon(
                  Icons.church,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),
                
                // Welcome Text
                const Text(
                  'Bem-vindo',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Faça login para acessar seus devocionais diários',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                // Email Field
                CustomEmailField(
                  controller: _emailController,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),
                
                // Password Field
                CustomPasswordField(
                  controller: _passwordController,
                  textInputAction: TextInputAction.done,
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 8),
                
                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPasswordDialog,
                    child: const Text(
                      'Esqueceu a senha?',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Login Button
                CustomButton(
                  text: 'Entrar',
                  onPressed: _handleEmailLogin,
                  isLoading: authState.isLoading,
                  width: double.infinity,
                ),
                const SizedBox(height: 24),
                
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'ou',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Google Sign-In Button
                CustomButton(
                  text: 'Continuar com Google',
                  onPressed: _handleGoogleLogin,
                  isLoading: authState.isLoading,
                  isOutlined: true,
                  icon: Icons.g_mobiledata,
                  width: double.infinity,
                  foregroundColor: Colors.black87,
                ),
                const SizedBox(height: 32),
                
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Não tem uma conta? ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: _navigateToRegister,
                      child: const Text(
                        'Cadastre-se',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ForgotPasswordDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends ConsumerState<_ForgotPasswordDialog> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendPasswordReset() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = Validators.sanitizeInput(_emailController.text);
      await ref.read(authNotifierProvider.notifier).sendPasswordResetEmail(email);
      
      if (mounted) {
        Navigator.of(context).pop();
        CustomSnackBar.showSuccess(
          context: context,
          message: 'Email de recuperação enviado! Verifique sua caixa de entrada.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    
    return AlertDialog(
      title: const Text('Recuperar Senha'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Digite seu email para receber as instruções de recuperação de senha.',
            ),
            const SizedBox(height: 16),
            CustomEmailField(
              controller: _emailController,
              validator: Validators.validateEmail,
            ),
          ],
        ),
      ),
      actions: [
        CustomButton(
          text: 'Cancelar',
          onPressed: () => Navigator.of(context).pop(),
          isOutlined: true,
        ),
        CustomButton(
          text: 'Enviar',
          onPressed: _sendPasswordReset,
          isLoading: authState.isLoading,
        ),
      ],
    );
  }
}