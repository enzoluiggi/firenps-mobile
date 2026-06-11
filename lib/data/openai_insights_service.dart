import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class OpenAiInsightsService {
  OpenAiInsightsService({
    http.Client? client,
    this.apiKey = const String.fromEnvironment('OPENAI_API_KEY'),
    this.model = const String.fromEnvironment(
      'OPENAI_MODEL',
      defaultValue: 'gpt-5.2',
    ),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String apiKey;
  final String model;

  bool get isConfigured => apiKey.trim().isNotEmpty;

  Future<String> generateInsights(String surveySummary) async {
    if (!isConfigured) {
      return 'Chave da OpenAI nao configurada.\n\n'
          'Para demonstrar com IA real, execute o app usando:\n'
          'flutter run --dart-define=OPENAI_API_KEY=SUA_CHAVE_AQUI';
    }

    http.Response response;
    try {
      // A chamada usa a Responses API da OpenAI para transformar os dados NPS
      // em um texto de analise. O app envia apenas o resumo montado localmente.
      response = await _client
          .post(
            Uri.parse('https://api.openai.com/v1/responses'),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': model,
              'input': [
                {
                  'role': 'developer',
                  'content':
                      'Voce e um analista de experiencia do cliente. Gere '
                      'insights claros, objetivos e em portugues do Brasil. '
                      'Organize em: Resumo executivo, Pontos positivos, '
                      'Pontos de atencao, Acoes recomendadas e Prioridade '
                      'para os proximos passos.',
                },
                {
                  'role': 'user',
                  'content':
                      'Analise os dados NPS abaixo e traga insights praticos:\n\n'
                      '$surveySummary',
                },
              ],
            }),
          )
          .timeout(const Duration(seconds: 45));
    } on TimeoutException {
      return 'A OpenAI demorou muito para responder.\n\n'
          'Tente novamente em alguns instantes.';
    } on http.ClientException catch (error) {
      return 'Nao foi possivel conectar na OpenAI.\n\n'
          'Verifique se o aparelho/emulador esta com internet e tente novamente.\n\n'
          '$error';
    } on FormatException catch (error) {
      return 'A resposta da IA veio em um formato inesperado.\n\n$error';
    } catch (error) {
      return 'Ocorreu um erro ao gerar insights pela IA.\n\n$error';
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return 'Nao foi possivel gerar insights pela IA.\n\n'
          'Status: ${response.statusCode}\n'
          'Resposta: ${response.body}';
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final outputText = body['output_text'];
    if (outputText is String && outputText.trim().isNotEmpty) {
      return outputText.trim();
    }

    return _extractTextFromOutput(body);
  }

  String _extractTextFromOutput(Map<String, dynamic> body) {
    final output = body['output'];
    final buffer = StringBuffer();

    if (output is List) {
      for (final item in output) {
        if (item is! Map<String, dynamic>) {
          continue;
        }

        final content = item['content'];
        if (content is! List) {
          continue;
        }

        for (final contentItem in content) {
          if (contentItem is Map<String, dynamic>) {
            final text = contentItem['text'];
            if (text is String) {
              buffer.writeln(text);
            }
          }
        }
      }
    }

    final text = buffer.toString().trim();
    if (text.isEmpty) {
      return 'A IA respondeu, mas o app nao conseguiu ler o texto retornado.';
    }
    return text;
  }
}
