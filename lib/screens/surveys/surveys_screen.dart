import 'package:flutter/material.dart';

import '../../data/fire_nps_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_shell_widgets.dart';

class SurveysScreen extends StatelessWidget {
  const SurveysScreen({super.key, required this.controller});

  final FireNpsController controller;

  @override
  Widget build(BuildContext context) {
    final surveys = controller.companySurveys;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // A tela de Pesquisas agora mostra somente as pesquisas ja cadastradas.
        // O cadastro de nova pesquisa foi removido desta opcao do menu.
        for (final survey in surveys)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: FireCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    survey.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    survey.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: survey.isActive
                              ? AppColors.success.withValues(alpha: 0.12)
                              : AppColors.muted.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          survey.isActive ? 'Ativa' : 'Inativa',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: survey.isActive
                                    ? AppColors.success
                                    : AppColors.muted,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // As datas abaixo usam os valores ja cadastrados em cada pesquisa.
                  Text(
                    'Inicio: ${_formatDate(survey.startDate)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Fim: ${_formatDate(survey.endDate)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
