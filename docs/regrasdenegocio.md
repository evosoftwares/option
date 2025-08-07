1. Visão Geral e Estratégia de Negócio OPTION
1.1. Conceito Central
Uma plataforma de mobilidade urbana (Ride-Hailing) que funciona como um mercado de duas faces (two-sided marketplace), conectando Passageiros que necessitam de transporte a Condutores que oferecem o serviço.
1.2. Proposta de Valor e Diferenciais
O projeto se diferencia por focar no empoderamento do Condutor, oferecendo um modelo de negócio mais justo e flexível. Isso é alcançado através de:
Precificação Flexível: O Condutor tem controle granular sobre os componentes de distância e tempo do valor da corrida.
Controle sobre Serviços: O Condutor define previamente quais serviços adicionais oferece e as taxas correspondentes.
Controle Geográfico: O Condutor pode excluir bairros ou zonas onde não deseja atuar.
Transparência e Escolha: O Passageiro escolhe ativamente o Condutor desejado de uma lista filtrada e transparente, já sabendo o preço final.
O objetivo estratégico é atrair e reter os melhores Condutores, o que, por consequência, resultará em um serviço de maior qualidade e disponibilidade para os Passageiros, criando um ciclo virtuoso de crescimento.
2. Atores do Ecossistema
O Passageiro (Passenger): O cliente final. Utiliza a aplicação para solicitar, acompanhar, pagar e avaliar viagens.
O Condutor (Driver): O prestador de serviço. Utiliza a aplicação para configurar seu perfil, definir seus preços e áreas de atuação, ficar online, aceitar e completar viagens.
O Administrador (Admin): A equipe de gestão da plataforma. Utiliza um painel de controle web para supervisionar a operação, gerir usuários, definir parâmetros globais e comunicar-se com a base de usuários.
3. Fluxo de Negócio Detalhado: Passageiro
3.1. Onboarding e Gestão de Conta
Registo:
O usuário cria uma conta usando E-mail e Senha.
Um perfil de usuário (AppUser) é criado no Firestore, associado ao seu UID do Firebase Auth.
O usuário deve aceitar os Termos de Serviço e Política de Privacidade no momento do cadastro.
Gestão de Perfil (ProfileScreen):
Visualizar e editar informações básicas (Nome, Foto, Telefone).
Endereços Salvos (SavedPlacesService):
Funcionalidade para adicionar, editar e remover endereços favoritos (ex: "Casa", "Trabalho") para agilizar a solicitação.
Histórico de Viagens (TripHistoryService):
Acesso a uma lista de todas as viagens passadas, com detalhes como rota, Condutor, valor pago e data.
3.2. Solicitação de Viagem (Fluxo Principal)
Passo 1: Definir Destino
Na tela inicial, o Passageiro insere o endereço de destino. O ponto de partida é automaticamente preenchido com a localização atual do GPS.
Passo 2: Confirmar Origem e Rota
O Passageiro é levado a uma tela com o mapa, mostrando a rota sugerida.
Ele pode ajustar o pino no mapa para definir o ponto de embarque exato.
O sistema calcula a distância e o tempo estimado para o trajeto principal (Origem -> Destino).
Passo 3: Selecionar Categoria e Preferências
O Passageiro seleciona a categoria do veículo (ex: "Carro Comum", "Carro 7 lugares", "Frete", "Guincho").
O Passageiro marca suas necessidades específicas. Para a categoria de transporte de passageiros, estas funcionarão como filtros obrigatórios:
Precisa de Ar-Condicionado?
Leva Animal de Estimação (Pet)?
Precisa de Porta-Malas Grande (Mercado)?
Destino/Origem é em Condomínio?
Número de Paradas no Trajeto: (O usuário pode inserir a quantidade, ex: 1, 2, 3).
Passo 4: Escolha do Condutor (Matching)
O sistema executa o algoritmo de matching (detalhado na Seção 5).
É exibida uma lista vertical com os 10 Condutores mais próximos que atendem a todos os critérios. A lista deve ser atualizada em tempo real (ver seção 5.3).
Cada item da lista mostra:
Foto, Nome e Avaliação (estrelas) do Condutor.
Marca, modelo e cor do veículo.
Preço Total da Viagem: Valor final, já incluindo todas as taxas.
Tempo Estimado de Chegada: Tempo para o Condutor chegar ao ponto de embarque.
Distância do Condutor: Distância atual do Condutor até o Passageiro.
Passo 5: Confirmação e Pedido
O Passageiro toca no Condutor desejado para confirmar a solicitação.
Verificação de Disponibilidade: Antes de confirmar o pedido, o sistema realiza uma verificação final para garantir que o Condutor ainda está disponível.
Cenário de Sucesso: Se o Condutor estiver disponível, a solicitação é confirmada, seu status é alterado para "Em Viagem", e a notificação push é enviada exclusivamente para ele.
Cenário de Concorrência: Se o Condutor não estiver mais disponível, o Passageiro recebe uma mensagem imediata (ex: "Este condutor não está mais disponível. Por favor, escolha outro.") e o Condutor é removido da lista.
3.3. Durante a Viagem
Aguardando Aceite: A tela do Passageiro mostra que o pedido foi enviado e aguarda a confirmação do Condutor.
Condutor a Caminho: Após o aceite, a interface muda para mostrar os detalhes do Condutor, sua posição no mapa, e os botões de Chat e Ligar.
Viagem Iniciada: Quando o Condutor inicia a corrida, o mapa atualiza para mostrar o progresso até o destino.
Alteração de Rota: O Passageiro pode solicitar a alteração do destino. O Condutor recebe um pedido para aceitar ou recusar a alteração.
3.4. Pós-Viagem e Pagamento
Finalização: Ao chegar ao destino, o Condutor finaliza a viagem no app.
Pagamento: A cobrança é processada automaticamente pelo Asaas.
Avaliação (RatingService): O Passageiro avalia o Condutor com estrelas e tags pré-definidas.
4. Fluxo de Negócio Detalhado: Condutor
4.1. Onboarding e Verificação
Registo Detalhado: O Condutor fornece dados pessoais, do veículo e envia fotos dos documentos (CNH, CRLV).
Aprovação Manual: O perfil fica em estado "Pendente" até que um Administrador verifique e aprove os documentos. O Condutor só pode ficar online após a aprovação.
Alteração de Perfil: Qualquer alteração subsequente em dados críticos do perfil (ex: veículo, CNH) fará com que o perfil retorne ao estado "Pendente" até uma nova liberação do administrador.
4.2. Configuração do Perfil de Trabalho
No seu perfil, o Condutor tem controle total sobre as seguintes configurações:
Ajuste de Ganhos (Dinâmico):
Preço por KM Personalizado: Pode definir um valor exato por quilômetro que substitui o valor padrão da plataforma.
Multiplicador de Tempo: Pode definir um multiplicador (ex: 1.2x) que se aplica sobre o valor por minuto da corrida.
Política de Ar-Condicionado: Define se trabalha com ar Sempre Ligado, Sempre Desligado ou Conforme Solicitação.
Serviços Adicionais e Taxas: Ativa os serviços que oferece e define o valor fixo que cobrará por cada um:
Aceita Pet? -> Taxa de Transporte Pet: R$ [valor]
Faz Serviço de Mercado? -> Taxa de Uso do Porta-Malas: R$ [valor]
Entra em Condomínios? -> Taxa de Acesso a Condomínio: R$ [valor]
Aceita Viagens com Paradas? -> Taxa por Parada: R$ [valor] (esta taxa será multiplicada pelo número de paradas solicitado pelo passageiro).
Áreas de Atendimento (Zonas de Exclusão):
O Condutor pode definir bairros ou zonas específicas onde não deseja receber solicitações de viagem.
A funcionalidade permitirá ao condutor pesquisar e selecionar bairros (usando uma interface de mapa/lista, como um place picker) que serão adicionados a uma "lista de exclusão".
Esta lista (excluded_neighborhoods) será salva no seu perfil no Firestore.
4.3. Disponibilidade e Aceitação de Viagens
Ficar Online: O Condutor ativa o botão "Ficar Online" para se tornar elegível para receber solicitações.
Receber Solicitação: Ao ser escolhido, recebe uma notificação com os detalhes da viagem e os ganhos estimados.
Decisão: O Condutor tem 10 segundos para Aceitar ou Recusar. Se o tempo expirar, a solicitação é automaticamente recusada.
4.4. Realização da Viagem
Navegar até o Passageiro: Após aceitar, o app exibe a rota para o ponto de embarque.
Iniciar Viagem: Ao encontrar o Passageiro, desliza um botão para "Iniciar Viagem".
Navegar até o Destino: O app mostra a rota para o destino final.
Finalizar Viagem: Ao chegar, desliza um botão para "Finalizar Viagem".
4.5. Pós-Viagem e Gestão
Ganhos: O valor da viagem (descontada a comissão) é creditado em sua carteira.
Painel de Controle: Acesso a um dashboard com histórico de viagens, ganhos e avaliações.
Avaliação: O Condutor também avalia o Passageiro.
5. Lógica Central: Matching, Precificação e Concorrência
5.1. Algoritmo de Matching (Passo a Passo)
Query Inicial: O sistema busca Condutores online na categoria selecionada e num raio de 10 km.
Filtragem por Zona de Exclusão:
O sistema obtém os bairros de origem e destino da solicitação do Passageiro.
Para cada Condutor na lista, o sistema verifica se o bairro de origem OU o bairro de destino da viagem está na sua lista de exclusão (excluded_neighborhoods).
Se houver uma correspondência, o Condutor é removido da lista de candidatos para esta viagem.
Filtragem por Preferências:
Se a categoria for "Transporte de Passageiros", o sistema filtra os Condutores restantes com base nas preferências marcadas pelo Passageiro (Pet, Ar-condicionado, etc.).
Para as demais categorias (ex: Frete, Guincho), este filtro de preferências é ignorado.
Cálculo de Preço Individual: Para cada Condutor elegível, o sistema calcula o preço final da viagem usando a fórmula da seção 5.2.
Ordenação e Limite: A lista é ordenada pela distância (do mais próximo ao mais distante).
Exibição: Os 10 primeiros Condutores são exibidos para o Passageiro.
5.2. Fórmula de Precificação
PreçoTotal = PreçoBase + TaxasAdicionais
PreçoBase = ComponenteDistancia + ComponenteTempo
ComponenteDistancia = PreçoKM_Aplicado * DistânciaTotal
ComponenteTempo = (ValorBaseMin * TempoTotal) * MultiplicadorTempo_Condutor
TaxasAdicionais: Soma das taxas fixas, incluindo a TaxaPorParada multiplicada pelo número de paradas.
Distância/Tempo Total: Incluem o trajeto do Condutor até o Passageiro e o trajeto da viagem principal.
5.3. Gerenciamento de Estado em Tempo Real e Concorrência
Listener em Tempo Real: A tela de seleção do Passageiro observa mudanças no status dos Condutores em tempo real. Se um Condutor ficar indisponível, sua opção na lista é desativada visualmente.
Transação Atômica na Seleção: A escolha do Condutor é uma transação que verifica e altera o status do Condutor de "online" para "em viagem" de forma atômica para evitar que dois passageiros selecionem o mesmo motorista.
6. Regras de Cancelamento e Políticas
(Nenhuma alteração nesta seção)
7. Sistemas Adicionais
7.1. Sistema de Pagamento
(Nenhuma alteração nesta seção)
7.2. Sistema de Comunicação
(Nenhuma alteração nesta seção)
7.3. Painel de Administração
O painel web deve permitir ao Admin:
Gestão de Usuários: Visualizar, aprovar, suspender e reativar contas.
Configurações Globais:
Definir o Valor Base por KM e Valor Base por Minuto para cada categoria.
Definir a percentagem de comissão da plataforma.
Comunicação: Enviar notificações push em massa ou segmentadas para os Condutores, com filtros que incluem segmentação por cidades.
Suporte: Visualizar detalhes de viagens para auxiliar na resolução de disputas.