# 📁 Estrutura de Organização do Projeto

## **Nova Arquitetura - Components vs Pages**

Este documento descreve a nova estrutura organizacional implementada no projeto para melhor separação de responsabilidades e reutilização de código.

## **🎯 Convenções de Nomenclatura**

### **Pages** (`*_page.dart`)
- **Propósito**: Componentes full-screen navegáveis (rotas)
- **Responsabilidades**: 
  - Gerenciar rotas e navegação
  - Integrar providers e lógica de negócio
  - Coordenar múltiplos components/widgets
  - Estados da aplicação de alto nível

### **Components** (`*_component.dart`)
- **Propósito**: Componentes reutilizáveis complexos
- **Responsabilidades**:
  - Lógica UI complexa com estado local
  - Interações e comportamentos específicos
  - Composição de múltiplos widgets
  - Funcionalidades bem definidas e encapsuladas

### **Widgets** (`*_widget.dart`)
- **Propósito**: Widgets UI puros e simples
- **Responsabilidades**:
  - UI pura, orientada por props
  - Sem lógica de negócio
  - Máxima reutilização
  - Elementos visuais básicos

## **📂 Estrutura de Pastas**

```
/lib/
  /features/
    /{feature_name}/
      /data/                    # Camada de dados
      /domain/                  # Camada de domínio
      /presentation/
        /pages/                 # Rotas/telas completas (*_page.dart)
        /components/            # Componentes complexos (*_component.dart)
        /widgets/               # Widgets simples (*_widget.dart)
        /providers/             # State management (Riverpod)
  /shared/
    /components/                # Componentes reutilizáveis cross-feature
    /widgets/                   # Widgets simples cross-feature
    /services/                  # Serviços compartilhados
  /core/
    /design_system/             # Design tokens, temas, constantes
```

## **🔄 Migração Realizada**

### **Eliminação de Inconsistências**
- ❌ **Antes**: Mistura de `/pages/` e `/screens/`
- ✅ **Depois**: Padronização total em `/pages/`

### **Renomeações Realizadas**

#### **Transport Feature**
- `confirm_pickup_screen.dart` → `confirm_pickup_page.dart`
- `bottom_pickup_panel.dart` → `components/bottom_pickup_panel_component.dart`
- `address_search_sheet.dart` → `components/address_search_sheet_component.dart`
- `my_location_button.dart` → `widgets/my_location_button_widget.dart`

#### **Location Tracking Feature**
- `screens/location_tracking_screen.dart` → `pages/location_tracking_page.dart`
- `location_tracking_controls.dart` → `components/location_tracking_controls_component.dart`
- `location_display.dart` → `widgets/location_display_widget.dart`

#### **Passenger Feature**
- `passenger_bottom_sheet.dart` → `components/passenger_bottom_sheet_component.dart`

#### **Chat Feature**
- `chat_input.dart` → `components/chat_input_component.dart`
- `message_bubble.dart` → `widgets/message_bubble_widget.dart`
- `conversation_tile.dart` → `widgets/conversation_tile_widget.dart`
- `start_chat_button.dart` → `widgets/start_chat_button_widget.dart`

#### **Shared Components**
- `widgets/empty_state.dart` → `components/empty_state_component.dart`
- `widgets/place_picker_field.dart` → `components/place_picker_field_component.dart`

## **📋 Exemplos de Uso**

### **Page (Rota)**
```dart
// pages/home_page.dart
class HomePage extends ConsumerStatefulWidget {
  // Gerencia providers, navegação, estado de alto nível
}
```

### **Component (Complexo)**
```dart
// components/chat_input_component.dart
class ChatInputComponent extends StatelessWidget {
  // Lógica de input, validação, callbacks
}
```

### **Widget (Simples)**
```dart
// widgets/message_bubble_widget.dart
class MessageBubbleWidget extends StatelessWidget {
  // UI pura baseada em props
}
```

## **✅ Benefícios da Nova Estrutura**

1. **🔍 Previsibilidade**: Desenvolvedores sabem exatamente onde encontrar cada tipo de componente
2. **🔧 Manutenibilidade**: Separação clara de responsabilidades facilita manutenção
3. **♻️ Reutilização**: Components bem organizados promovem maior reutilização
4. **📏 Consistência**: Padrões uniformes em todo o projeto
5. **📈 Escalabilidade**: Estrutura preparada para crescimento futuro
6. **🧪 Testabilidade**: Componentes isolados são mais fáceis de testar

## **🎨 Design System Integration**

A nova estrutura trabalha em conjunto com o design system centralizado:
- **Design Tokens** (`/core/design_system/design_tokens.dart`)
- **Cores padronizadas**, **espaçamentos consistentes**, **tipografia escalável**
- **Componentes reutilizáveis** seguem os design tokens

## **📖 Guidelines de Desenvolvimento**

### **Ao criar um novo componente, pergunte-se:**
1. **É uma rota/tela completa?** → `/pages/`
2. **Tem lógica complexa e estado?** → `/components/`  
3. **É UI pura orientada por props?** → `/widgets/`
4. **É reutilizável em múltiplas features?** → `/shared/`

### **Nomenclatura de Classes:**
```dart
// Page
class UserProfilePage extends ConsumerStatefulWidget

// Component  
class ChatInputComponent extends StatefulWidget

// Widget
class MessageBubbleWidget extends StatelessWidget
```

---
**📝 Documento criado durante refatoração de arquitetura**  
**🗓️ Data**: Janeiro 2025  
**👥 Responsável**: Sistema de IA Claude