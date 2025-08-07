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



0. Regras de Design e Código   

REGRA PRINCIPAL: Não utilizar código de exemplo ou mockado no projeto. Todo código deve ser funcional e direcionado aos requisitos reais do sistema.



I. Princípios Fundamentais de Design e Código

Estes são os princípios mais universais, aplicáveis a quase todo tipo de programação.
KISS (Keep It Simple, Stupid / Mantenha Simples, Estúpido): Privilegie a simplicidade e evite complexidades desnecessárias. A solução mais simples costuma ser a mais robusta e fácil de manter.
DRY (Don't Repeat Yourself / Não se Repita): Cada parte do conhecimento ou lógica de um sistema deve ter uma representação única e inequívoca. Evite código duplicado.
YAGNI (You Ain't Gonna Need It / Você Não Vai Precisar Disso): Não adicione funcionalidades com base em suposições sobre o futuro. Implemente apenas o que é necessário agora.
SoC (Separation of Concerns / Separação de Preocupações): Separe o software em seções distintas, cada uma abordando uma preocupação (funcionalidade) específica. Isso leva a um código mais modular e coeso.
Principle of Least Astonishment (POLA / Princípio da Menor Surpresa): O resultado de uma operação deve ser óbvio, consistente e previsível para o usuário ou desenvolvedor. A interface deve se comportar como esperado.
Code for the Maintainer: Escreva o código pensando que você (ou outra pessoa) precisará entendê-lo e modificá-lo no futuro. Clareza é mais importante do que astúcia.

II. Princípios de Programação Orientada a Objetos (POO)

Estes são essenciais para um bom design em linguagens como Flutter, Dart.
SOLID:
S - Single Responsibility Principle (Princípio da Responsabilidade Única): Uma classe deve ter apenas um motivo para mudar, ou seja, uma única responsabilidade.
O - Open/Closed Principle (Princípio Aberto/Fechado): As entidades de software devem ser abertas para extensão, mas fechadas para modificação.
L - Liskov Substitution Principle (Princípio da Substituição de Liskov): Objetos de uma subclasse devem ser substituíveis por objetos de sua superclasse sem afetar a corretude do programa.
I - Interface Segregation Principle (Princípio da Segregação de Interface): É melhor ter várias interfaces específicas para o cliente do que uma única interface de propósito geral.
D - Dependency Inversion Principle (Princípio da Inversão de Dependência): Módulos de alto nível não devem depender de módulos de baixo nível. Ambos devem depender de abstrações.
Composition over Inheritance (Composição sobre Herança): Prefira compor objetos (uma classe "tem um" objeto de outra) a herdar de uma classe base (uma classe "é um" tipo de outra). Isso oferece mais flexibilidade.
Law of Demeter (LoD / Lei de Deméter): Um objeto deve ter conhecimento limitado sobre outros objetos. Evite longas cadeias de chamadas (ex: a.getB().getC().doSomething()), pois isso aumenta o acoplamento.

III. Princípios de Arquitetura e Estrutura

Estes guiam o design de sistemas maiores e a interação entre seus componentes.
Convention over Configuration (CoC / Convenção sobre Configuração): Um framework deve tomar decisões sensatas por padrão para diminuir a quantidade de configuração que um desenvolvedor precisa fazer.
Robustness Principle (Princípio da Robustez ou Lei de Postel): "Seja conservador no que você faz, seja liberal no que você aceita dos outros." Ao enviar dados, seja estrito e conforme o padrão. Ao receber dados, seja flexível e aceite formatos não-padrão se a intenção for clara.
Common Closure Principle (CCP): Classes que mudam juntas devem ser agrupadas. Se uma mudança em um requisito do sistema afeta um conjunto de classes, essas classes devem pertencer ao mesmo pacote ou módulo.
Common Reuse Principle (CRP): Classes que são reutilizadas juntas devem ser agrupadas. Não force os usuários de um pacote a depender de coisas de que não precisam.

IV. Princípios de Usabilidade e Interface

Focados na interação entre o software e o ser humano.
Error-prevention over error-correction (Prevenção de Erro sobre Correção de Erro): É melhor projetar um sistema que impeça o usuário de cometer erros do que um que simplesmente lida bem com eles depois que acontecem.
Feedback: O sistema deve sempre informar ao usuário o que está acontecendo, fornecendo feedback apropriado em um tempo razoável após uma ação.
Minimize cognitive load (Minimizar a Carga Cognitiva): Não sobrecarregue o usuário com muitas informações ou opções de uma só vez. Apresente a informação de forma clara e em pedaços gerenciáveis.


