import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../data/fire_nps_controller.dart';
import '../../models/nps_response.dart';
import '../../models/nps_insights.dart';
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
  NpsInsights? generatedInsights;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _LoadingInsightsView();
    }

    if (generatedInsights != null) {
      return Screenshot(
        controller: _screenshotController,
        child: _InsightsResultView(
          insights: generatedInsights!,
          onRegenerate: _generateInsights,
          onShare: _shareInsightsAsPdf,
          onExit: () {
            // Ao clicar em sair, a tela volta para o estado inicial dos insights.
            setState(() => generatedInsights = null);
          },
        ),
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

    await widget.controller.generateNpsInsights();

    if (!mounted) {
      return;
    }

    setState(() {
      isLoading = false;
      generatedInsights = widget.controller.currentNpsInsights;
    });
  }

  Future<void> _shareInsightsAsPdf() async {
    final image = await _screenshotController.capture();
    if (image == null) return;

    final pdf = pw.Document();
    final pdfImage = pw.MemoryImage(image);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
          );
        },
      ),
    );

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/insights_nps.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Confira os Insights da IA sobre o NPS em PDF',
    );
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
    required this.insights,
    required this.onRegenerate,
    required this.onShare,
    required this.onExit,
  });

  final NpsInsights insights;
  final VoidCallback onRegenerate;
  final VoidCallback onShare;
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
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onShare,
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('PDF'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(onPressed: onExit, child: const Text('Sair')),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        _InsightTextCard(title: 'Resumo Executivo', text: insights.resumoExecutivo),
        const SizedBox(height: 12),
        _InsightTextCard(title: 'Sentimento Geral', text: insights.sentimentoGeral),
        const SizedBox(height: 12),
        _InsightTextCard(title: 'Pontos Positivos', text: insights.pontosPositivos.join('\n')),
        const SizedBox(height: 12),
        _InsightTextCard(title: 'Pontos de Atenção', text: insights.pontosDeAtencao.join('\n')),
        const SizedBox(height: 12),
        _InsightTextCard(title: 'Principais Reclamações', text: insights.principaisReclamacoes.join('\n')),
        const SizedBox(height: 12),
        _InsightTextCard(title: 'Ações Recomendadas', text: insights.acoesRecomendadas.join('\n')),
        const SizedBox(height: 12),
        _InsightTextCard(title: 'Prioridade para os Próximos Passos', text: insights.prioridadePassos),
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
