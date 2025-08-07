# Sistema de Chat - InDriver App

Este módulo implementa um sistema completo de chat em tempo real entre motoristas e passageiros usando Firebase Firestore.

## Estrutura do Módulo

```
features/chat/
├── data/
│   ├── models/          # Modelos de dados
│   ├── repositories/    # Implementações dos repositórios
│   └── services/        # Serviços de comunicação com Firebase
├── domain/
│   └── repositories/    # Interfaces dos repositórios
└── presentation/
    ├── pages/          # Telas do chat
    ├── providers/      # Gerenciamento de estado
    └── widgets/        # Componentes reutilizáveis
```

## Componentes Principais

### 1. Modelos de Dados

- **ChatMessage**: Representa uma mensagem individual
- **ChatConversation**: Representa uma conversa entre motorista e passageiro
- **ChatParticipant**: Informações dos participantes da conversa

### 2. Telas

- **ChatListPage**: Lista todas as conversas do usuário
- **ChatPage**: Interface de chat individual com mensagens em tempo real

### 3. Widgets Auxiliares

- **ConversationTile**: Item da lista de conversas
- **MessageBubble**: Bolha de mensagem individual
- **ChatInput**: Campo de entrada de mensagens
- **StartChatButton**: Botão para iniciar nova conversa

## Como Usar

### 1. Iniciar uma Nova Conversa

```dart
import 'package:provider/provider.dart';
import '../features/chat/presentation/widgets/start_chat_button.dart';

// Em uma tela de corrida ativa, adicione:
StartChatButton(
  rideId: ride.id,
  driverId: ride.driverId,
  driverName: ride.driverName,
  passengerId: currentUser.id,
  passengerName: currentUser.name,
  buttonText: 'Conversar com motorista',
)
```

### 2. Navegar para Lista de Conversas

```dart
import 'package:go_router/go_router.dart';

// Navegar para a lista de conversas
context.push('/chat');
```

### 3. Abrir Conversa Específica

```dart
// Navegar para uma conversa específica
context.push('/chat/${conversationId}');
```

## Funcionalidades Implementadas

### ✅ Funcionalidades Básicas
- [x] Criação de conversas automática
- [x] Envio e recebimento de mensagens em tempo real
- [x] Lista de conversas com preview da última mensagem
- [x] Status de leitura das mensagens
- [x] Indicador de usuário online/offline
- [x] Contador de mensagens não lidas
- [x] Interface responsiva e intuitiva

### ✅ Recursos Avançados
- [x] Diferentes tipos de mensagem (texto, imagem, localização)
- [x] Status de entrega das mensagens
- [x] Timestamp das mensagens
- [x] Agrupamento de mensagens por data
- [x] Scroll automático para novas mensagens
- [x] Gerenciamento de estado reativo

### 🔄 Em Desenvolvimento
- [ ] Envio de imagens
- [ ] Compartilhamento de localização
- [ ] Chamadas de voz/vídeo
- [ ] Notificações push
- [ ] Bloqueio de usuários
- [ ] Relatório de usuários

## Fluxo de Uso

1. **Passageiro solicita corrida**: Sistema cria automaticamente uma conversa
2. **Iniciar chat**: Passageiro clica em "Conversar com motorista"
3. **Troca de mensagens**: Ambos podem enviar mensagens em tempo real
4. **Status de leitura**: Mensagens mostram quando foram lidas
5. **Histórico**: Conversas ficam salvas na lista de chats

## Configuração Firebase

Certifique-se de que o Firebase Firestore está configurado com as seguintes coleções:

- `conversations`: Armazena as conversas
- `messages`: Armazena as mensagens individuais

## Navegação

O sistema está integrado à navegação principal do app:
- Aba "Chat" na bottom navigation
- Rotas: `/chat` e `/chat/:conversationId`

## Dependências

- Firebase Firestore para persistência
- Provider para gerenciamento de estado
- GoRouter para navegação
- Intl para formatação de datas

## Segurança

- Usuários só podem ver suas próprias conversas
- Mensagens são associadas a corridas específicas
- Validação de permissões no backend (Firebase Rules)