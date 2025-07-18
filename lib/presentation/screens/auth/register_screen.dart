import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_snackbar.dart';
import '../../../core/utils/validators.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      final name = Validators.sanitizeInput(_nameController.text);
      final email = Validators.sanitizeInput(_emailController.text);
      final password = _passwordController.text;
      
      await ref.read(authNotifierProvider.notifier).registerWithEmail(email, password, name);
    }
  }

  void _handleGoogleSignUp() async {
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
  }

  void _navigateToLogin() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    
    // Show error messages
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: _navigateToLogin,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // App Logo/Icon
                const Icon(
                  Icons.church,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),
                
                // Welcome Text
                const Text(
                  'Criar Conta',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Crie sua conta para começar sua jornada espiritual',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                // Name Field
                CustomNameField(
                  label: 'Nome completo',
                  hint: 'Digite seu nome completo',
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 16),
                
                // Email Field
                CustomEmailField(
                  controller: _emailController,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),
                
                // Password Field
                CustomPasswordField(
                  hint: 'Digite sua senha (mín. 6 caracteres)',
                  controller: _passwordController,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 16),
                
                // Confirm Password Field
                CustomPasswordField(
                  label: 'Confirmar senha',
                  hint: 'Digite sua senha novamente',
                  controller: _confirmPasswordController,
                  textInputAction: TextInputAction.done,
                  validator: (value) => Validators.validatePasswordConfirmation(
                    value,
                    _passwordController.text,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Register Button
                CustomButton(
                  text: 'Criar Conta',
                  onPressed: _handleRegister,
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
                
                // Google Sign-Up Button
                CustomButton(
                  text: 'Continuar com Google',
                  onPressed: _handleGoogleSignUp,
                  isLoading: authState.isLoading,
                  isOutlined: true,
                  icon: Icons.g_mobiledata,
                  width: double.infinity,
                  foregroundColor: Colors.black87,
                ),
                const SizedBox(height: 32),
                
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Já tem uma conta? ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: _navigateToLogin,
                      child: const Text(
                        'Faça login',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Terms and Privacy
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Ao criar uma conta, você concorda com nossos Termos de Uso e Política de Privacidade.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}