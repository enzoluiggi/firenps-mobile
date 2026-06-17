# 🔥 FireNPS Mobile

O **FireNPS Mobile** é uma aplicação desenvolvida em **Flutter** que atua como complemento da plataforma **FireNPS Web**.

Seu principal objetivo é permitir que gestores acompanhem indicadores de satisfação do cliente, consultem relatórios e realizem análises automatizadas por Inteligência Artificial diretamente em dispositivos móveis.

---

# 🚀 Funcionalidades Principais

O aplicativo está estruturado em quatro módulos principais:

## 📊 Dashboard Mobile

* Visualização do NPS geral;
* Exibição da zona de classificação:

  * Excelência
  * Qualidade
  * Aperfeiçoamento
  * Crítica
* Total de respostas recebidas;
* Gráficos de distribuição de notas:

  * Promotores
  * Neutros
  * Detratores

## 📝 Gestão de Pesquisas

* Listagem detalhada das pesquisas cadastradas;
* Visualização de:

  * Status
  * Descrição
  * Período de vigência

## 🤖 Fire Insights (IA)

Módulo de análise avançada que utiliza a API da OpenAI para transformar comentários qualitativos em relatórios estruturados contendo:

* Resumo executivo;
* Sentimento geral;
* Principais insights;
* Sugestões de ações.

## 📄 Relatórios e Exportação

* Filtros por pesquisa;
* Filtros por período;
* Exportação e compartilhamento de dados nos formatos:

  * CSV
  * XLSX (Excel)
  * PDF

---

# 🛠️ Tecnologias e Arquitetura

O projeto foi desenvolvido utilizando as seguintes tecnologias:

| Categoria               | Tecnologia       |
| ----------------------- | ---------------- |
| Linguagem               | Dart             |
| Framework               | Flutter          |
| Banco de Dados Local    | SQLite (sqflite) |
| Inteligência Artificial | API da OpenAI    |

### Estrutura do Projeto

* **Screens** — Telas da aplicação;
* **Models** — Representação das entidades de negócio;
* **Controllers** — Controle das regras e fluxo da aplicação;
* **Themes** — Padronização visual;
* **Widgets** — Componentes reutilizáveis.

---

# 📦 Dependências Principais

| Biblioteca   | Finalidade                    |
| ------------ | ----------------------------- |
| `http`       | Comunicação com APIs externas |
| `sqflite`    | Persistência local            |
| `path`       | Manipulação de caminhos       |
| `excel`      | Geração de planilhas          |
| `pdf`        | Geração de documentos PDF     |
| `screenshot` | Captura de componentes        |
| `share_plus` | Compartilhamento de arquivos  |

---

# ⚙️ Como Executar o Projeto

## Pré-requisitos

* Flutter SDK instalado;
* Dispositivo Android/iOS ou emulador compatível;
* Chave de API da OpenAI.

## Execução

Por questões de segurança, a chave da API não deve permanecer fixa no código-fonte.

```bash
flutter run --dart-define=OPENAI_API_KEY=SUA_CHAVE_AQUI
```

---

# 📊 Módulos Detalhados

## 🔐 Autenticação

Permite:

* Login de usuários;
* Cadastro de usuários;
* Persistência local de dados da empresa e do perfil do usuário.

## 📋 Pesquisas

Exibe:

* Título;
* Descrição;
* Status;
* Datas de vigência.

## 🧠 Insights

Gera análises estruturadas contendo:

* Pontos positivos;
* Pontos de atenção;
* Reclamações recorrentes;
* Prioridades de ação.

## ⚙️ Configurações

Permite:

* Gerenciamento do perfil do usuário;
* Encerramento de sessão (logout).

---

# 👨‍💻 Equipe de Desenvolvimento

**Desenvolvedores**

* Enzo Luiggi
* João Pedro Marques Alves

**Data:** Junho de 2026.
