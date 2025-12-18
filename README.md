# Chat App

Aplicação de chat em tempo real desenvolvida com Flutter e Firebase, implementando autenticação de usuários e troca de mensagens instantâneas.

## Sobre o Projeto

Este projeto foi desenvolvido como parte do processo seletivo para desenvolvedor Flutter na Flugo. A aplicação demonstra a implementação de um sistema de chat funcional com foco em arquitetura limpa, boas práticas de desenvolvimento e experiência do usuário.

## Funcionalidades

- Autenticação de usuários (email/senha)
- Sistema de cadastro com validações
- Chat global em tempo real
- Identificação visual de mensagens próprias e de outros usuários
- Exibição de nome do remetente e timestamp
- Scroll automático para novas mensagens
- Interface responsiva e intuitiva
- Suporte a temas claro e escuro

## Arquitetura

O projeto segue o padrão **MVVM (Model-View-ViewModel)** com separação clara de responsabilidades:

```
lib/
├── config/              # Configurações gerais (tema)
├── models/              # Modelos de dados
├── services/            # Camada de serviços (Firebase)
├── viewmodels/          # Lógica de negócio e gerenciamento de estado
├── views/               # Telas da aplicação
├── widgets/             # Componentes reutilizáveis
├── firebase_options.dart # Configuração Firebase (FlutterFire CLI)
└── main.dart            # Entry point
```

### Camadas

**Models**: Estruturas de dados imutáveis com serialização/deserialização para Firebase

**Services**: Abstração das operações do Firebase (Auth e Realtime Database)

**ViewModels**: Gerenciamento de estado com Provider, contendo toda lógica de negócio

**Views**: Componentes de UI stateless sempre que possível, observando os ViewModels

**Widgets**: Componentes reutilizáveis e modulares

## Tecnologias Utilizadas

- **Flutter 3.38.3** (via FVM)
- **Firebase Authentication** - Autenticação de usuários
- **Firebase Realtime Database** - Sincronização de mensagens em tempo real
- **Provider** - Gerenciamento de estado
- **Material Design 3** - Design system

## Configuração do Ambiente

### Pré-requisitos

- Flutter 3.38.3
- FVM instalado
- Conta no Firebase

### Firebase Setup

1. Crie um projeto no [Firebase Console](https://console.firebase.google.com/)

2. Ative o **Firebase Authentication**:
   - Acesse Authentication > Sign-in method
   - Habilite o provedor "Email/Password"

3. Ative o **Realtime Database**:
   - Acesse Realtime Database
   - Crie um banco de dados em modo de teste
   - **IMPORTANTE**: As regras de segurança serão configuradas no próximo passo

4. Configure o FlutterFire:

```bash
# Instale o FlutterFire CLI se ainda não tiver
dart pub global activate flutterfire_cli

# Configure o Firebase para o projeto
flutterfire configure
```

Isso criará os arquivos de configuração necessários:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `macos/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart`

5. **Configure as Regras de Segurança** (CRÍTICO):

Deploy as regras de segurança para o Firebase Realtime Database:

```bash
# Instale o Firebase CLI se ainda não tiver
npm install -g firebase-tools

# Faça login no Firebase
firebase login

# Inicialize o Firebase no projeto (se ainda não fez)
firebase init database

# Deploy das regras de segurança
firebase deploy --only database
```

As regras estão definidas em `database.rules.json` e incluem:
- ✅ Autenticação obrigatória para todas as operações
- ✅ Validação de dados (tipos, tamanhos)
- ✅ Controle de acesso por usuário
- ✅ Proteção contra spam (limite de 1000 caracteres por mensagem)
- ✅ Usuários só podem enviar mensagens em seu próprio nome

**⚠️ ATENÇÃO SEGURANÇA:**
- Os arquivos `google-services.json` e `GoogleService-Info.plist` contêm API keys
- Esses arquivos **NÃO** devem ser commitados no git
- Use os arquivos `.example` como referência
- Configure suas próprias credenciais localmente

### Instalação

```bash
# Clone o repositório
git clone <repository-url>

# Entre no diretório
cd chat_app_firebase

# Use a versão correta do Flutter
fvm use 3.38.3

# Instale as dependências
fvm flutter pub get

# Execute o aplicativo
fvm flutter run
```

## Estrutura de Dados

### Realtime Database Schema

```
/
├── messages/                    # Chat global
│   └── {messageId}
│       ├── text: string
│       ├── senderName: string
│       ├── senderId: string
│       └── timestamp: number
│
├── privateMessages/             # Mensagens privadas
│   └── {chatId}
│       └── {messageId}
│           ├── text: string
│           ├── senderName: string
│           ├── senderId: string
│           ├── timestamp: number
│           ├── chatId: string
│           └── readBy: {userId: boolean}
│
├── chats/                       # Metadados das conversas
│   └── {chatId}
│       ├── participantIds: {userId: true}
│       ├── participantNames: {userId: name}
│       ├── lastMessage: string
│       ├── lastMessageTime: number
│       ├── isTyping: {userId: boolean}
│       └── unreadCount: {userId: number}
│
└── users/                       # Presença dos usuários
    └── {userId}
        ├── uid: string
        ├── email: string
        ├── displayName: string
        └── fcmToken: string (opcional)
```

## Decisões Técnicas

- **MVVM**: Escolhido para garantir separação de responsabilidades e facilitar testes
- **Provider**: Solução nativa e performática para gerenciamento de estado
- **Realtime Database**: Escolhido sobre Firestore pela natureza do chat (alta frequência de updates)
- **StreamBuilder**: Utilizado para reatividade em tempo real
- **Material Design 3**: Interface moderna e consistente com as guidelines do Flutter

## Segurança

O projeto implementa múltiplas camadas de segurança:

### Autenticação
- Firebase Authentication com email/senha
- Validação de credenciais no client-side e server-side
- Mensagens de erro amigáveis sem expor informações sensíveis

### Regras de Banco de Dados
- Autenticação obrigatória para todas as operações
- Usuários só podem ler/escrever em conversas das quais participam
- Validação de tipos de dados no server-side
- Proteção contra injeção de dados maliciosos
- Limite de 1000 caracteres por mensagem (anti-spam)

### Proteção de Credenciais
- Arquivos de configuração Firebase não commitados no git
- `.gitignore` configurado para proteger API keys
- Arquivos `.example` disponíveis como template

### Validações Client-Side
- Validação de email e senha no formulário
- Verificação de campos obrigatórios
- Sanitização de inputs

## Melhorias Futuras

- [ ] Implementação de salas de chat
- [ ] Upload de imagens
- [ ] Indicador de "digitando..."
- [ ] Notificações push
- [ ] Paginação de mensagens
- [ ] Busca de mensagens
- [ ] Testes unitários e de widget

## Licença

Este projeto foi desenvolvido para fins educacionais e de avaliação técnica.
