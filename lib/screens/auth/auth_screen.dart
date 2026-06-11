import 'package:flutter/material.dart';

import '../../data/fire_nps_controller.dart';
import '../../theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.controller});

  final FireNpsController controller;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isRegisterMode = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();
  final companyController = TextEditingController();
  final segmentController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    companyController.dispose();
    segmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Text('🔥', style: TextStyle(fontSize: 34)),
                  const SizedBox(height: 8),
                  Text(
                    'FireNPS',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    'Entre na sua conta',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: 26),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'E-mail',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(controller: emailController),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Senha',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(controller: passwordController, obscureText: true),
                  if (isRegisterMode) ...[
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Nome completo',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(controller: fullNameController),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Empresa',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(controller: companyController),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Segmento',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(controller: segmentController),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        if (isRegisterMode) {
                          await widget.controller.register(
                            fullName: fullNameController.text,
                            email: emailController.text,
                            password: passwordController.text,
                            companyName: companyController.text,
                            segment: segmentController.text,
                          );
                        } else {
                          await widget.controller.login(
                            email: emailController.text,
                            password: passwordController.text,
                          );
                        }

                        if (mounted) {
                          setState(() {});
                        }
                      },
                      child: Text(isRegisterMode ? 'Cadastrar' : 'Entrar'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      setState(() => isRegisterMode = !isRegisterMode);
                    },
                    child: Text(
                      isRegisterMode ? 'Ja tenho conta' : 'Criar nova conta',
                    ),
                  ),
                  if (widget.controller.authMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      widget.controller.authMessage!,
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
