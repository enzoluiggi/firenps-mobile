import 'package:flutter/material.dart';

import '../../data/fire_nps_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_shell_widgets.dart';
import '../shared/company_panels.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.controller});

  final FireNpsController controller;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? selectedSurveyId;
  DateTimeRange? selectedRange;

  @override
  Widget build(BuildContext context) {
    // Estes dados sao usados na parte de relatorios que foi mesclada no Dashboard.
    final reportMetrics = widget.controller.metricsForSurvey(
      selectedSurveyId,
      selectedRange,
    );
    final distribution = widget.controller.distributionForSurvey(
      selectedSurveyId,
      selectedRange,
    );

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        ScoreSummaryCard(
          score: reportMetrics.score.toStringAsFixed(0),
          zone: reportMetrics.zone,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            MetricStat(
              value: '${reportMetrics.promoterRate.toStringAsFixed(0)}%',
              label: 'Promotores',
              color: AppColors.success,
            ),
            const SizedBox(width: 8),
            MetricStat(
              value: '${reportMetrics.neutralRate.toStringAsFixed(0)}%',
              label: 'Neutros',
              color: AppColors.warning,
            ),
            const SizedBox(width: 8),
            MetricStat(
              value: '${reportMetrics.detractorRate.toStringAsFixed(0)}%',
              label: 'Detratores',
              color: AppColors.danger,
            ),
          ],
        ),
        const SizedBox(height: 8),
        FireCard(
          child: Column(
            children: [
              SimpleInfoRow(
                label: 'Total de respostas',
                value: '${reportMetrics.total}',
              ),
              SimpleInfoRow(
                label: 'Pesquisas criadas',
                value: '${widget.controller.companySurveys.length}',
              ),
              SimpleInfoRow(
                label: 'Contatos cadastrados',
                value: '${widget.controller.companyContacts.length}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        FireCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(label: 'Distribuicao'),
              const SizedBox(height: 12),
              DistributionPieChart(
                promoterPercent: reportMetrics.promoterRate,
                neutralPercent: reportMetrics.neutralRate,
                detractorPercent: reportMetrics.detractorRate,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        FireCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(label: 'Notas'),
              const SizedBox(height: 12),
              ScoreBarChart(distribution: distribution),
            ],
          ),
        ),
        const SizedBox(height: 8),
        FireCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(label: 'Acoes rapidas'),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () =>
                      showContactsPanel(context, widget.controller),
                  child: const Text('Ver contatos'),
                ),
              ),
              if (widget.controller.canManageCompany) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => showAdminPanel(context, widget.controller),
                    child: const Text('Abrir painel administrativo'),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        FireCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(label: 'Relatorios'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                initialValue: selectedSurveyId,
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Todas as pesquisas'),
                  ),
                  ...widget.controller.companySurveys.map(
                    (survey) => DropdownMenuItem<String?>(
                      value: survey.id,
                      child: Text(survey.title),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => selectedSurveyId = value),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _selectDateRange,
                      child: Text(
                        selectedRange == null
                            ? 'dd/mm/aaaa'
                            : _formatDate(selectedRange!.start),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _selectDateRange,
                      child: Text(
                        selectedRange == null
                            ? 'dd/mm/aaaa'
                            : _formatDate(selectedRange!.end),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showCsvPreview,
            icon: const Icon(Icons.download_outlined),
            label: const Text('Exportar CSV'),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      initialDateRange: selectedRange,
    );
    if (picked != null) {
      setState(() => selectedRange = picked);
    }
  }

  void _showCsvPreview() {
    final csv = widget.controller.exportResponsesAsCsv(
      selectedSurveyId,
      selectedRange,
    );
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(child: SelectableText(csv)),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
