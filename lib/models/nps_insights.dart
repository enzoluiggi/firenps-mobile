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
    String toStringValue(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      return value.toString();
    }

    List<String> toStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((e) => toStringValue(e)).toList();
      }
      return [toStringValue(value)];
    }

    return NpsInsights(
      resumoExecutivo: toStringValue(json['resumo_executivo']),
      sentimentoGeral: toStringValue(json['sentimento_geral']),
      pontosPositivos: toStringList(json['pontos_positivos']),
      pontosDeAtencao: toStringList(json['pontos_de_atencao']),
      principaisReclamacoes: toStringList(json['principais_reclamacoes']),
      acoesRecomendadas: toStringList(json['acoes_recomendadas']),
      prioridadePassos: toStringValue(json['prioridade_passos']),
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
