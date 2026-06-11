import 'package:flutter/material.dart';

import '../../data/fire_nps_controller.dart';
import '../../models/nps_response.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_shell_widgets.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key, required this.controller});

  final FireNpsController controller;

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  var isLoading = false;
  String? generatedInsights;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _LoadingInsightsView();
    }

    if (generatedInsights != null) {
      return _InsightsResultView(
        text: generatedInsights!,
        onRegenerate: _generateInsights,
        onExit: () {
          // Ao clicar em sair, a tela volta para o estado inicial dos insights.
          setState(() => generatedInsights = null);
        },
      );
    }

    return _StartInsightsView(onGenerate: _generateInsights);
  }

  Future<void> _generateInsights() async {
    if (isLoading) {
      return;
    }

    setState(() {
      isLoading = true;
      generatedInsights = null;
    });

    // Este delay simula o tempo de processamento da analise.
    // Nao existe chamada de API aqui; tudo e calculado com os dados locais.
    await Future<void>.delayed(const Duration(seconds: 2));

    if (!mounted) {
      return;
    }

    setState(() {
      isLoading = false;
      generatedInsights = _buildFakeInitialAnalysis();
    });
  }

  String _buildFakeInitialAnalysis() {
    final responses = widget.controller.companyResponses;
    if (responses.isEmpty) {
      return 'Analise inicial\n\n'
          'Ainda nao existem respostas cadastradas para gerar insights.\n\n'
          'Cadastre ou responda uma pesquisa NPS para que o sistema consiga '
          'avaliar notas, comentarios e pontos de melhoria.';
    }

    final metrics = widget.controller.metricsForSurvey(null, null);
    final buffer = StringBuffer();

    final average = responses.isEmpty
        ? 0.0
        : responses.map((item) => item.score).reduce((a, b) => a + b) /
              responses.length;

    final lowScoreComments = responses
        .where((item) => item.classification == NpsClassification.detractor)
        .where((item) => item.comment.trim().isNotEmpty)
        .map((item) => '- ${item.contactName}: "${item.comment}"')
        .take(3)
        .toList();

    final highScoreComments = responses
        .where((item) => item.classification == NpsClassification.promoter)
        .where((item) => item.comment.trim().isNotEmpty)
        .map((item) => '- ${item.contactName}: "${item.comment}"')
        .take(3)
        .toList();

    final responsesByRegion = <String, List<NpsResponse>>{};
    for (final response in responses) {
      // O mapa agrupa as respostas por regiao para descobrir onde ha mais
      // risco ou melhor satisfacao.
      responsesByRegion.putIfAbsent(response.region, () => []).add(response);
    }

    String? criticalRegion;
    double? criticalRegionScore;
    responsesByRegion.forEach((region, regionResponses) {
      final promoters = regionResponses
          .where((item) => item.classification == NpsClassification.promoter)
          .length;
      final detractors = regionResponses
          .where((item) => item.classification == NpsClassification.detractor)
          .length;
      final score = ((promoters - detractors) / regionResponses.length) * 100;

      if (criticalRegionScore == null || score < criticalRegionScore!) {
        criticalRegion = region;
        criticalRegionScore = score;
      }
    });

    buffer.writeln('Analise inicial');
    buffer.writeln('');
    buffer.writeln('Resumo executivo');
    buffer.writeln(
      'O NPS geral esta em ${metrics.score.toStringAsFixed(0)} '
      '(${metrics.zone}), com ${metrics.total} respostas analisadas e '
      'nota media ${average.toStringAsFixed(1)}.',
    );
    buffer.writeln('');
    buffer.writeln('Distribuicao das respostas');
    buffer.writeln(
      '- Promotores: ${metrics.promoters} '
      '(${metrics.promoterRate.toStringAsFixed(0)}%)',
    );
    buffer.writeln(
      '- Neutros: ${metrics.neutrals} '
      '(${metrics.neutralRate.toStringAsFixed(0)}%)',
    );
    buffer.writeln(
      '- Detratores: ${metrics.detractors} '
      '(${metrics.detractorRate.toStringAsFixed(0)}%)',
    );

    final regionToHighlight = criticalRegion;
    final scoreToHighlight = criticalRegionScore;
    if (regionToHighlight != null && scoreToHighlight != null) {
      buffer.writeln('');
      buffer.writeln('Ponto de atencao por regiao');
      buffer.writeln(
        'A regiao $regionToHighlight merece prioridade, pois apresenta o menor '
        'NPS regional (${scoreToHighlight.toStringAsFixed(0)}).',
      );
    }

    if (highScoreComments.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('Pontos positivos observados');
      buffer.writeln(highScoreComments.join('\n'));
    }

    if (lowScoreComments.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('Pontos de atencao observados');
      buffer.writeln(lowScoreComments.join('\n'));
    }

    buffer.writeln('');
    buffer.writeln('Acoes recomendadas');
    buffer.writeln('- Entrar em contato primeiro com clientes detratores.');
    buffer.writeln(
      '- Investigar comentarios sobre demora, confusao ou falta de acompanhamento.',
    );
    buffer.writeln(
      '- Reforcar os pontos citados por promotores no atendimento.',
    );
    buffer.writeln('- Acompanhar a evolucao do NPS depois das melhorias.');

    return buffer.toString().trim();
  }
}

class _StartInsightsView extends StatelessWidget {
  const _StartInsightsView({required this.onGenerate});

  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: FireCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'FireInsights',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Use IA para gerar insights sobre os comentarios e pesquisas NPS',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onGenerate,
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: const Text('Gerar insights'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingInsightsView extends StatelessWidget {
  const _LoadingInsightsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: FireCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
              Text(
                'Gerando insights...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightsResultView extends StatelessWidget {
  const _InsightsResultView({
    required this.text,
    required this.onRegenerate,
    required this.onExit,
  });

  final String text;
  final VoidCallback onRegenerate;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              onPressed: onRegenerate,
              icon: const Icon(Icons.refresh_outlined),
              label: const Text('Gerar novamente'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: onExit, child: const Text('Sair')),
          ],
        ),
        const SizedBox(height: 12),
        _InsightTextCard(title: 'Analise inicial', text: text),
      ],
    );
  }
}

class _InsightTextCard extends StatelessWidget {
  const _InsightTextCard({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return FireCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          // SelectableText deixa o usuario copiar a analise se quiser usar em
          // relatorios, trabalhos ou apresentacoes.
          SelectableText(
            text.isEmpty
                ? 'Nenhuma informacao encontrada para analisar.'
                : text,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
