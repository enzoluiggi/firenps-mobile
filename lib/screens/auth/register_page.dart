import 'package:flutter/material.dart';

import '../../data/fire_nps_controller.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.controller});

  final FireNpsController controller;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // O cadastro tambem grava no SQLite, entao esperamos finalizar antes de
    // conferir se houve erro.
    await widget.controller.register(
      fullName: fullNameController.text,
      email: emailController.text,
      password: passwordController.text,
    );

    if (!mounted) {
      return;
    }

    final message = widget.controller.authMessage;
    if (message != null && !widget.controller.isAuthenticated) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  String? _validateRequired(String? value, String label) {
    if ((value?.trim() ?? '').isEmpty) {
      return 'Informe $label.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Informe seu e-mail.';
    }
    if (!text.contains('@')) {
      return 'Informe um e-mail valido.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final text = value?.trim() ?? '';
    if (text.length < 4) {
      return 'Use ao menos 4 caracteres.';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if ((value?.trim() ?? '').isEmpty) {
      return 'Confirme sua senha.';
    }
    if (value != passwordController.text) {
      return 'As senhas precisam ser iguais.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final headline = Theme.of(context).textTheme.headlineMedium;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      const AppLogo(height: 180, width: double.infinity),
                      const SizedBox(height: 24),
                      Text(
                        'Criar conta',
                        style: headline?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        controller: fullNameController,
                        label: 'Nome Completo',
                        prefixIcon: Icons.person_outline,
                        validator: (value) =>
                            _validateRequired(value, 'seu nome completo'),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        label: 'E-mail',
                        prefixIcon: Icons.email_outlined,
                        validator: _validateEmail,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: passwordController,
                        obscureText: true,
                        label: 'Senha',
                        prefixIcon: Icons.lock_outline,
                        validator: _validatePassword,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        label: 'Confirmacao de Senha',
                        prefixIcon: Icons.lock_outline,
                        validator: _validateConfirmPassword,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(label: 'Criar conta', onPressed: _registrar),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Ja tenho conta'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
