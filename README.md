# firenps2

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## Configuração da Análise de Insights com IA

Para utilizar a funcionalidade de análise de insights com Inteligência Artificial (OpenAI), siga os passos abaixo:

### 1. Obter uma Chave de API da OpenAI

You precisará de uma chave de API válida da OpenAI. Se você não tiver uma, pode obtê-la em [https://platform.openai.com/account/api-keys](https://platform.openai.com/account/api-keys).

### 2. Executar o Aplicativo com a Chave de API

Para que o aplicativo utilize a sua chave de API da OpenAI, você deve passá-la como uma variável de ambiente ao executar o aplicativo Flutter. Abra o terminal na raiz do projeto (`firenps-mobile-main`) e execute o seguinte comando:

```bash
flutter run --dart-define=OPENAI_API_KEY=SUA_CHAVE_AQUI
```

**Substitua `SUA_CHAVE_AQUI` pela sua chave de API real da OpenAI.**

### 3. Gerar Insights no Aplicativo

Após executar o aplicativo:

1.  Navegue até a tela de **Insights**.
2.  Clique no botão **"Gerar insights"**.
3.  O aplicativo enviará os comentários das respostas NPS para a API da OpenAI, que retornará uma análise estruturada em JSON. Os insights serão exibidos na tela, categorizados em:
    *   Resumo Executivo
    *   Sentimento Geral
    *   Pontos Positivos
    *   Pontos de Atenção
    *   Principais Reclamações
    *   Ações Recomendadas
    *   Prioridade para os Próximos Passos

### Observações:

*   A análise de insights funcionará melhor com um volume razoável de comentários nas respostas NPS.
*   Certifique-se de que seu dispositivo ou emulador tenha conexão com a internet para que o aplicativo possa se comunicar com a API da OpenAI.
*   Em caso de erros, verifique o console do Flutter para mensagens de log que podem indicar problemas com a chave de API ou com a resposta da OpenAI.

## Estrutura do Projeto (Revisada)

As seguintes modificações foram realizadas no projeto:

*   **`lib/data/openai_insights_service.dart`**: Modificado para usar o endpoint de `chat/completions` da OpenAI, com um prompt mais detalhado para solicitar análise de sentimento e foco das reclamações em formato JSON. A função `generateInsights` agora retorna um objeto `NpsInsights`.
*   **`lib/models/nps_insights.dart`**: Novo arquivo de modelo de dados para representar os insights estruturados retornados pela API da OpenAI.
*   **`lib/data/fire_nps_controller.dart`**: Adicionado um método `generateNpsInsights` que orquestra a chamada ao `OpenAiInsightsService` e armazena os insights gerados.
*   **`lib/screens/insights/insights_screen.dart`**: Atualizado para exibir os insights de NPS de forma estruturada, utilizando o novo modelo `NpsInsights` e chamando o método `generateNpsInsights` do controller.

---

**Desenvolvido por Manus AI**
