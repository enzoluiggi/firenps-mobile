import 'dart:async';
import 'dart:developer' as dev;
import 'dart:convert';
import '../models/nps_insights.dart';

import 'package:http/http.dart' as http;

class OpenAiInsightsService {
  OpenAiInsightsService({
    http.Client? client,
    this.apiKey = const String.fromEnvironment('OPENAI_API_KEY'),
    this.model = const String.fromEnvironment(
      'OPENAI_MODEL',
      defaultValue: 'gpt-4o',
    ),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String apiKey;
  final String model;

  bool get isConfigured => apiKey.trim().isNotEmpty;

  Future<NpsInsights> generateInsights(String surveySummary) async {
    if (!isConfigured) {
      throw Exception('Chave da OpenAI nao configurada.');
    }

    http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse('https://api.openai.com/v1/chat/completions'),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': model,
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'Você é um analista de experiência do cliente. Sua tarefa é analisar os dados de NPS fornecidos e gerar insights detalhados em português do Brasil, no formato JSON. O JSON deve conter os seguintes campos:\n\n' +
                      '- `resumo_executivo`: Um resumo conciso dos principais achados.\n' +
                      '- `sentimento_geral`: O sentimento predominante (positivo, negativo, neutro) com base nos comentários.\n' +
                      '- `pontos_positivos`: Uma lista de pontos positivos identificados.\n' +
                      '- `pontos_de_atencao`: Uma lista de pontos que requerem atenção.\n' +
                      '- `principais_reclamacoes`: Uma lista dos principais temas de reclamação, com exemplos de comentários.\n' +
                      '- `acoes_recomendadas`: Sugestões de ações para melhorar a experiência.\n' +
                      '- `prioridade_passos`: Prioridade para os próximos passos.\n\n' +
                      'Certifique-se de que a saída seja um JSON válido e que todos os campos estejam preenchidos de forma clara e objetiva.',
                },
                {
                  'role': 'user',
                  'content':
                      'Analise os dados NPS abaixo e traga insights praticos:\n\n'
                      '$surveySummary',
                },
              ],
              'response_format': {'type': 'json_object'},
            }),
          )
          .timeout(const Duration(seconds: 45));
    } on TimeoutException {
      throw Exception('A OpenAI demorou muito para responder.');
    } on http.ClientException catch (error) {
      throw Exception('Nao foi possivel conectar na OpenAI: $error');
    } on FormatException catch (error) {
      throw Exception('A resposta da IA veio em um formato inesperado: $error');
    } catch (error) {
      throw Exception('Ocorreu um erro ao gerar insights pela IA: $error');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Nao foi possivel gerar insights pela IA. Status: ${response.statusCode}, Resposta: ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final outputText = body['choices'][0]['message']['content'];
    if (outputText is String && outputText.trim().isNotEmpty) {
      try {
        final insightsJson = jsonDecode(outputText) as Map<String, dynamic>;
        return NpsInsights.fromJson(insightsJson);
      } catch (e) {
        dev.log('Erro ao parsear JSON da OpenAI: $e');
        throw Exception('Erro ao processar insights da IA: $e');
      }
    } else {
      dev.log("Resposta inesperada da OpenAI: $body");
      throw Exception("A IA respondeu, mas o app não conseguiu ler o texto retornado.");
    }
  }
}
