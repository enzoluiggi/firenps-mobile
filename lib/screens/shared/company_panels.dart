import 'package:flutter/material.dart';

import '../../data/fire_nps_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_shell_widgets.dart';

void showContactsPanel(BuildContext context, FireNpsController controller) {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(label: 'Contatos'),
              const SizedBox(height: 12),
              for (final contact in controller.companyContacts)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: FireCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(contact.email),
                        Text(
                          contact.phone,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.muted,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    controller.addContact(
                      name: nameController.text,
                      email: emailController.text,
                      phone: phoneController.text,
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Adicionar contato'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showAdminPanel(BuildContext context, FireNpsController controller) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(label: 'Painel administrativo'),
              const SizedBox(height: 12),
              for (final user in controller.companyUsers)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: FireCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(user.email),
                        Text(
                          '${user.role} - ${user.companyName}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.muted,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              const SectionTitle(label: 'Avaliacoes recentes'),
              const SizedBox(height: 12),
              for (final response in controller.companyResponses.take(5))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: FireCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${response.contactName} - nota ${response.score}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(response.comment),
                        const SizedBox(height: 4),
                        Text(
                          '${response.region} - ${response.state}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.muted,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}
