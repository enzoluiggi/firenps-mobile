🔥 FireNPS Mobile
O FireNPS Mobile é uma aplicação desenvolvida em Flutter que serve como complemento mobile à plataforma FireNPS Web. Seu principal objetivo é permitir que gestores acompanhem indicadores de satisfação do cliente, acessem relatórios e realizem análises automatizadas via Inteligência Artificial diretamente em dispositivos móveis.
🚀 Funcionalidades Principais
O aplicativo está estruturado em quatro módulos principais:

    Dashboard Mobile: Visualização do NPS geral, zona de classificação (Excelência, Qualidade, Aperfeiçoamento ou Crítica), total de respostas e gráficos de distribuição de notas (promotores, neutros e detratores).
    Gestão de Pesquisas: Listagem detalhada de pesquisas cadastradas, incluindo status, descrição e período de vigência.
    Fire Insights (IA): Módulo de análise avançada que utiliza a API da OpenAI para transformar comentários qualitativos em relatórios estruturados com resumo executivo, sentimento geral e sugestões de ações.
    Relatórios e Exportação: Filtros por pesquisa ou período, com suporte para exportação e compartilhamento de dados em formatos CSV, XLSX (Excel) e PDF.

🛠️ Tecnologias e Arquitetura
O projeto foi construído utilizando as seguintes tecnologias e padrões:

    Linguagem & Framework: Dart e Flutter.
    Banco de Dados Local: SQLite (via plugin sqflite) para persistência de dados de autenticação e perfil do usuário.
    Inteligência Artificial: Integração com a API da OpenAI.
    Arquitetura: Organizada em camadas de telas (screens), modelos (models), controladores, temas e widgets reutilizáveis.

📦 Dependências Principais
O projeto utiliza as seguintes bibliotecas:

    http: Comunicação com APIs externas.
    sqflite & path: Banco de dados local.
    excel: Geração de planilhas.
    pdf & screenshot: Geração de relatórios visuais.
    share_plus: Compartilhamento de arquivos.

⚙️ Como Executar o Projeto
Pré-requisitos

    Flutter SDK instalado.
    Dispositivo Android/iOS ou emulador compatível.
    Chave de API da OpenAI (necessária para o módulo Fire Insights).

Execução
Para garantir a segurança, a chave da API não deve ficar fixa no código. Execute o aplicativo utilizando variáveis de ambiente:

flutter run --dart-define=OPENAI_API_KEY=SUA_CHAVE_AQUI

📊 Módulos Detalhados

    Autenticação: Permite login e cadastro de usuários com persistência local de dados da empresa e perfil.
    Pesquisas: Exibe título, descrição, status e datas das pesquisas.
    Insights: Gera uma análise estruturada contendo pontos positivos, pontos de atenção, reclamações recorrentes e prioridades de ação com base nos comentários dos clientes.
    Configurações: Gerenciamento do perfil do usuário e encerramento de sessão.

Desenvolvido por: Enzo Luiggi e João Pedro Marques Alves. Data: Junho de 2026.
