import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../data/fire_nps_controller.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.controller});

  final FireNpsController controller;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _executarLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // O login consulta o SQLite, por isso usamos await para esperar a resposta
    // antes de decidir se mostraremos mensagem de erro.
    await widget.controller.login(
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

  void _irParaRegistro() {
    Navigator.of(context).pushNamed(AppRoutes.register);
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
    if (text.isEmpty) {
      return 'Informe sua senha.';
    }
    if (text.length < 4) {
      return 'Use ao menos 4 caracteres.';
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
                        'Entrar',
                        style: headline?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
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
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(label: 'Entrar', onPressed: _executarLogin),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _irParaRegistro,
                        child: const Text('Criar conta'),
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
