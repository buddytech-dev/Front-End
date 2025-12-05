# BuddyTech - Frontend

BuddyTech é uma plataforma inteligente de gestão de vendas e relacionamento com clientes (CRM), potencializada por Inteligência Artificial para auxiliar vendedores a priorizar leads e fechar negócios com mais eficiência.

## 🚀 Funcionalidades Principais

*   **Dashboard do Vendedor:** Visão geral dos leads, métricas e tarefas do dia.
*   **Gestão de Leads:** Listagem e detalhes completos de clientes potenciais.
*   **Inteligência Artificial:**
    *   Scoring de leads e probabilidade de fechamento.
    *   Sugestões de próximos passos e tipo de contato ideal.
    *   Resumos automáticos de interações.
    *   Geração de scripts de vendas e emails personalizados.
*   **Histórico de Interações:** Registro completo de chamadas, emails e reuniões.
*   **Ranking de Vendedores:** Gamificação com classificação baseada em desempenho.
*   **Área Administrativa:** Gestão de usuários, contas e visão global do sistema.

## 🛠️ Tecnologias Utilizadas

*   **Framework:** [Flutter](https://flutter.dev/) (Dart)
*   **Gerenciamento de Estado:** `setState` (Nativo)
*   **Backend:** .NET Core API (Integrado via `ApiService`)
*   **Autenticação & Banco de Dados:** [Supabase](https://supabase.com/)
*   **Armazenamento Local:** `shared_preferences`
*   **UI/UX:** Material Design 3, Responsividade (Mobile & Web)

## 📂 Estrutura do Projeto

```
lib/
├── config/         # Configurações globais (Cores, Tema, API)
├── models/         # Modelos de dados (Classes de domínio)
├── pages/          # Telas da aplicação
│   ├── admin/      # Telas administrativas
│   └── ...         # Telas do vendedor (Home, Detalhes, Ranking, etc.)
├── routes/         # Definição de rotas e navegação
├── services/       # Serviços de API e lógica de negócios
└── utils/          # Utilitários (Formatadores, Responsividade)
```

## ⚙️ Configuração e Instalação

1.  **Pré-requisitos:**
    *   Flutter SDK instalado (versão estável mais recente).
    *   Conta no Supabase configurada.
    *   Backend da API rodando localmente ou em servidor.

2.  **Clonar o repositório:**
    ```bash
    git clone https://github.com/buddytech-dev/Front-End.git
    cd Front-End/buddytech
    ```

3.  **Configurar variáveis de ambiente:**
    Crie um arquivo `assets/.env` na raiz do projeto com as seguintes chaves:
    ```env
    SUPABASE_URL=sua_url_supabase
    SUPABASE_ANON_KEY=sua_chave_anonima_supabase
    ```

4.  **Instalar dependências:**
    ```bash
    flutter pub get
    ```

5.  **Executar o projeto:**
    ```bash
    flutter run
    ```

## 📱 Telas Principais

*   **Login:** Autenticação segura via Supabase.
*   **Home:** Lista de leads prioritários e acesso rápido às funções.
*   **Detalhes do Cliente:** O "coração" do app, onde o vendedor interage com o lead e recebe insights da IA.
*   **Ranking:** Visualização competitiva do desempenho da equipe.
*   **Histórico:** Linha do tempo de todas as interações com o cliente.

## 🤝 Contribuição

1.  Faça um Fork do projeto.
2.  Crie uma Branch para sua Feature (`git checkout -b feature/NovaFeature`).
3.  Faça o Commit de suas mudanças (`git commit -m 'Adiciona NovaFeature'`).
4.  Faça o Push para a Branch (`git push origin feature/NovaFeature`).
5.  Abra um Pull Request.

---
Desenvolvido pela equipe **BuddyTech**.

