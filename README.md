# TaskFlow - App de Tarefas (Flutter)

Este repositório contém o desenvolvimento do **TaskFlow**, um aplicativo moderno e elegante de gerenciamento de tarefas diárias em Flutter. O projeto foi desenvolvido como parte da Avaliação Continuada de Questão Aberta (ACQA).

---

## 🎨 Características do Projeto

*   **Design Vibrante e Premium**: Uso de paleta de cores moderna com tons de roxo (`#7C3AED`, `#5B21B6`), contrastes elegantes e tipografia limpa.
*   **Organização Robusta**: Estrutura de pastas modular que separa com precisão modelos, telas e serviços.
*   **Calendário Interativo**: Navegação mensal dinâmica com visualização dos dias e marcação de tarefas pendentes em tempo real.
*   **Regra de Ordenação Exigida**: As tarefas pendentes são sempre exibidas em primeiro lugar, seguidas pelas concluídas, ambas organizadas em **ordem alfabética**.
*   **Persistência em Memória**: Lógica centralizada em serviços com padrão de projeto Singleton.

---

## 📁 Estrutura de Pastas do Projeto

Os arquivos de código fonte `.dart` estão organizados da seguinte forma dentro da pasta `lib/`:

```text
lib/
├── main.dart                 # Ponto de entrada do aplicativo e tema global
├── models/
│   ├── task_model.dart       # Modelo de dados da Tarefa
│   └── user_model.dart       # Modelo de dados do Usuário
├── services/
│   ├── auth_service.dart     # Serviço Singleton de Autenticação em Memória
│   └── task_service.dart     # Serviço Singleton de Tarefas em Memória (com ordenação alfabética)
└── screens/
    ├── login_screen.dart     # Tela de Cadastro e Login com transições suaves
    ├── calendar_screen.dart  # Tela de Calendário dinâmico com dot indicators
    └── task_list_screen.dart # Tela de exibição de tarefas e estatísticas
```

---

## 🧠 Arquitetura e Decisões de Design

1.  **Singleton Pattern**: Os serviços `AuthService` e `TaskService` utilizam o padrão Singleton. Isso garante uma única instância global de controle de dados na memória do aplicativo, permitindo que diferentes telas acessem e modifiquem o estado de forma síncrona e rápida.
2.  **Separação de Responsabilidades (MVC/MVVM-like)**: As telas (`screens`) apenas renderizam a interface do usuário e delegam toda a lógica de manipulação e validação de dados para os serviços correspondentes (`services`). Os dados trafegam estruturados através dos modelos (`models`).
3.  **Algoritmo de Ordenação Personalizado**: No arquivo `task_service.dart`, a recuperação das tarefas diárias filtra e agrupa os elementos em duas listas distintas (pendentes e concluídas), ordenando cada uma alfabeticamente antes de concatená-las.
4.  **Ajuste de Robustez**: A operação de conclusão de tarefas (`toggleTask`) foi desenvolvida utilizando uma varredura segura para prevenir exceções como `StateError` caso uma referência inválida seja repassada.

---

## 🚀 Como Executar o Aplicativo

### Pré-requisitos
*   Flutter SDK instalado e configurado.
*   Dispositivo físico conectado ou emulador ativo.

### Passo a Passo
1.  Clone este repositório:
    ```bash
    git clone https://github.com/haristoneuGarcia/APP-DE-TAREFAS.git
    ```
2.  Navegue até a pasta do projeto:
    ```bash
    cd APP-DE-TAREFAS
    ```
3.  Gere as pastas nativas da plataforma (caso necessário):
    ```bash
    flutter create .
    ```
4.  Obtenha as dependências do Flutter:
    ```bash
    flutter pub get
    ```
5.  Execute o aplicativo:
    ```bash
    flutter run
    ```
