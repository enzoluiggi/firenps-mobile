import 'package:flutter/material.dart';

import '../../data/fire_nps_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_shell_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.controller});

  final FireNpsController controller;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController nameController;
  late final TextEditingController companyController;
  late final TextEditingController segmentController;
  late final TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    final user = widget.controller.currentUser;
    nameController = TextEditingController(text: user?.fullName ?? '');
    companyController = TextEditingController(text: user?.companyName ?? '');
    segmentController = TextEditingController(
      text: user?.businessSegment ?? '',
    );
    emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    companyController.dispose();
    segmentController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.controller.currentUser;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        FireCard(
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                foregroundColor: AppColors.primary,
                child: const Icon(Icons.person_outline),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? '',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      user?.email ?? '',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                    ),
                    Text(
                      user?.companyName ?? '',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        FireCard(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome completo'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: companyController,
                decoration: const InputDecoration(labelText: 'Empresa'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: segmentController,
                decoration: const InputDecoration(labelText: 'Segmento'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'E-mail'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () async {
              // Aguarda o SQLite atualizar os dados antes de avisar o usuario.
              await widget.controller.updateProfile(
                fullName: nameController.text,
                companyName: companyController.text,
                segment: segmentController.text,
              );
              if (!context.mounted) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Perfil atualizado.')),
              );
            },
            child: const Text('Salvar alteracoes'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF4F57),
            ),
            onPressed: widget.controller.logout,
            child: const Text('Sair da Conta'),
          ),
        ),
      ],
    );
  }
}
