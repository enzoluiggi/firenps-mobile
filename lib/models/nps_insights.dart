import 'dart:convert';

class NpsInsights {
  final String resumoExecutivo;
  final String sentimentoGeral;
  final List<String> pontosPositivos;
  final List<String> pontosDeAtencao;
  final List<String> principaisReclamacoes;
  final List<String> acoesRecomendadas;
  final String prioridadePassos;

  NpsInsights({
    required this.resumoExecutivo,
    required this.sentimentoGeral,
    required this.pontosPositivos,
    required this.pontosDeAtencao,
    required this.principaisReclamacoes,
    required this.acoesRecomendadas,
    required this.prioridadePassos,
  });

  factory NpsInsights.fromJson(Map<String, dynamic> json) {
    return NpsInsights(
      resumoExecutivo: json['resumo_executivo'] as String,
      sentimentoGeral: json['sentimento_geral'] as String,
      pontosPositivos: List<String>.from(json['pontos_positivos'] as List),
      pontosDeAtencao: List<String>.from(json['pontos_de_atencao'] as List),
      principaisReclamacoes: List<String>.from(json['principais_reclamacoes'] as List),
      acoesRecomendadas: List<String>.from(json['acoes_recomendadas'] as List),
      prioridadePassos: json['prioridade_passos'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resumo_executivo': resumoExecutivo,
      'sentimento_geral': sentimentoGeral,
      'pontos_positivos': pontosPositivos,
      'pontos_de_atencao': pontosDeAtencao,
      'principais_reclamacoes': principaisReclamacoes,
      'acoes_recomendadas': acoesRecomendadas,
      'prioridade_passos': prioridadePassos,
    };
  }

  @override
  String toString() {
    return 'Resumo Executivo: $resumoExecutivo\n\n' +
           'Sentimento Geral: $sentimentoGeral\n\n' +
           'Pontos Positivos: ${pontosPositivos.join(', ')}\n\n' +
           'Pontos de Atenção: ${pontosDeAtencao.join(', ')}\n\n' +
           'Principais Reclamações: ${principaisReclamacoes.join(', ')}\n\n' +
           'Ações Recomendadas: ${acoesRecomendadas.join(', ')}\n\n' +
           'Prioridade para os Próximos Passos: $prioridadePassos';
  }
}
