import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/fire_nps_controller.dart';
import '../../widgets/app_shell_widgets.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key, required this.controller});

  final FireNpsController controller;

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String? selectedSurveyId;
  DateTimeRange? selectedRange;

  @override
  Widget build(BuildContext context) {
    final metrics = widget.controller.metricsForSurvey(
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
        FireCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(label: 'Pesquisa'),
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
                      onPressed: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2025),
                          lastDate: DateTime(2030),
                          initialDateRange: selectedRange,
                        );
                        if (picked != null) {
                          setState(() => selectedRange = picked);
                        }
                      },
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
                      onPressed: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2025),
                          lastDate: DateTime(2030),
                          initialDateRange: selectedRange,
                        );
                        if (picked != null) {
                          setState(() => selectedRange = picked);
                        }
                      },
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
        ScoreSummaryCard(
          score: metrics.score.toStringAsFixed(0),
          zone: metrics.zone,
        ),
        const SizedBox(height: 8),
        FireCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(label: 'Distribuicao'),
              const SizedBox(height: 12),
              DistributionPieChart(
                promoterPercent: metrics.promoterRate,
                neutralPercent: metrics.neutralRate,
                detractorPercent: metrics.detractorRate,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    // Copia exatamente o texto gerado no CSV para a area de
                    // transferencia do aparelho ou computador.
                    await Clipboard.setData(ClipboardData(text: csv));
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'CSV copiado para a area de transferencia.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Copiar CSV'),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(child: SelectableText(csv)),
              ),
            ],
          ),
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
