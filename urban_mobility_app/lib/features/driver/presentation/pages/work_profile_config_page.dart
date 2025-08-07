import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/driver_work_config_provider.dart';
import '../../domain/models/driver_work_config.dart';
import '../../domain/models/excluded_zones.dart';

/// Página de Configuração do Perfil de Trabalho (Seção 4.2)
/// Implementa as funcionalidades de ajuste de ganhos, serviços adicionais e áreas de atendimento
class WorkProfileConfigPage extends StatefulWidget {
  const WorkProfileConfigPage({super.key});

  @override
  State<WorkProfileConfigPage> createState() => _WorkProfileConfigPageState();
}

class _WorkProfileConfigPageState extends State<WorkProfileConfigPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Carrega a configuração ao inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverWorkConfigProvider>().loadConfig();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuração de Trabalho'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.attach_money), text: 'Preços'),
            Tab(icon: Icon(Icons.room_service), text: 'Serviços'),
            Tab(icon: Icon(Icons.location_off), text: 'Áreas'),
          ],
        ),
        actions: [
          Consumer<DriverWorkConfigProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: const Icon(Icons.save),
                onPressed: provider.isLoading
                    ? null
                    : () => provider.saveConfig(),
              );
            },
          ),
        ],
      ),
      body: Consumer<DriverWorkConfigProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Erro: ${provider.error}'),
                  ElevatedButton(
                    onPressed: () => provider.loadConfig(),
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildPricingTab(provider),
              _buildServicesTab(provider),
              _buildAreasTab(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPricingTab(DriverWorkConfigProvider provider) {
    final config = provider.config;
    final pricing = config.pricingConfig;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ajuste de Ganhos (Dinâmico)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Configure seus preços personalizados para maximizar seus ganhos.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Usar Preços Personalizados'),
                    subtitle: const Text(
                      'Substitui os preços padrão da plataforma',
                    ),
                    value: pricing.useCustomPricing,
                    onChanged: (value) {
                      provider.toggleCustomPricing(value);
                    },
                  ),
                  if (pricing.useCustomPricing) ...[
                    const Divider(),
                    const Text(
                      'Preço por Quilômetro',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('R\$ '),
                        Expanded(
                          child: TextFormField(
                            initialValue: (pricing.customPricePerKm ?? 2.50)
                                .toStringAsFixed(2),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              hintText: '2.50',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              final price = double.tryParse(value);
                              if (price != null) {
                                provider.updateCustomPricePerKm(price);
                              }
                            },
                          ),
                        ),
                        const Text(' /km'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Multiplicador de Tempo',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: pricing.timeMultiplier,
                            min: 0.5,
                            max: 2.0,
                            divisions: 15,
                            label:
                                '${pricing.timeMultiplier.toStringAsFixed(1)}x',
                            onChanged: (value) {
                              provider.updateTimeMultiplier(value);
                            },
                          ),
                        ),
                        Text('${pricing.timeMultiplier.toStringAsFixed(1)}x'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Aplica sobre o valor por minuto da plataforma',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Política de Ar-Condicionado',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...AirConditioningPolicy.values.map((policy) {
                    return RadioListTile<AirConditioningPolicy>(
                      title: Text(policy.displayName),
                      subtitle: Text(policy.description),
                      value: policy,
                      groupValue: config.airConditioningPolicy,
                      onChanged: (value) {
                        if (value != null) {
                          provider.updateAirConditioningPolicy(value);
                        }
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesTab(DriverWorkConfigProvider provider) {
    final config = provider.config;
    final services = config.serviceFees;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Serviços Adicionais',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Configure os serviços extras que você oferece e suas taxas.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Transporte de Pet
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.pets, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Transporte de Pet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Switch(
                        value: services.petTransport.isActive,
                        onChanged: (value) {
                          provider.toggleService('pet', value);
                        },
                      ),
                    ],
                  ),
                  if (services.petTransport.isActive) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Taxa: R\$ '),
                        Expanded(
                          child: TextFormField(
                            initialValue: services.petTransport.fee
                                .toStringAsFixed(2),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              final fee = double.tryParse(value);
                              if (fee != null) {
                                provider.updateServiceFee('pet', fee);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Uso do Porta-Malas
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.luggage, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Uso do Porta-Malas (Mercado)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Switch(
                        value: services.trunkService.isActive,
                        onChanged: (value) {
                          provider.toggleService('trunk', value);
                        },
                      ),
                    ],
                  ),
                  if (services.trunkService.isActive) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Taxa: R\$ '),
                        Expanded(
                          child: TextFormField(
                            initialValue: services.trunkService.fee
                                .toStringAsFixed(2),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              final fee = double.tryParse(value);
                              if (fee != null) {
                                provider.updateServiceFee('trunk', fee);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Acesso a Condomínio
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.apartment, color: Colors.green),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Acesso a Condomínio',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Switch(
                        value: services.condominiumAccess.isActive,
                        onChanged: (value) {
                          provider.toggleService('condominium', value);
                        },
                      ),
                    ],
                  ),
                  if (services.condominiumAccess.isActive) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Taxa: R\$ '),
                        Expanded(
                          child: TextFormField(
                            initialValue: services.condominiumAccess.fee
                                .toStringAsFixed(2),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              final fee = double.tryParse(value);
                              if (fee != null) {
                                provider.updateServiceFee('condominium', fee);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Paradas no Trajeto
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Paradas no Trajeto',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Switch(
                        value: services.stopService.isActive,
                        onChanged: (value) {
                          provider.toggleService('stop', value);
                        },
                      ),
                    ],
                  ),
                  if (services.stopService.isActive) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Taxa por parada: R\$ '),
                        Expanded(
                          child: TextFormField(
                            initialValue: services.stopService.fee
                                .toStringAsFixed(2),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              final fee = double.tryParse(value);
                              if (fee != null) {
                                provider.updateServiceFee('stop', fee);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreasTab(DriverWorkConfigProvider provider) {
    final excludedZones = provider.config.excludedZones;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Áreas de Atendimento',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddNeighborhoodDialog(provider),
                icon: const Icon(Icons.add),
                label: const Text('Excluir Bairro'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Configure os bairros/zonas que você não deseja atender.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),

          if (excludedZones.neighborhoods.isEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.location_city,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nenhum bairro excluído',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Você está disponível para atender em todas as áreas.',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Card(
              child: Column(
                children: excludedZones.neighborhoods.map((neighborhood) {
                  return ListTile(
                    leading: const Icon(Icons.location_off, color: Colors.red),
                    title: Text(neighborhood.name),
                    subtitle: Text(
                      '${neighborhood.city} - ${neighborhood.state}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        provider.removeExcludedNeighborhood(
                          neighborhood.name,
                          neighborhood.city,
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddNeighborhoodDialog(DriverWorkConfigProvider provider) {
    final nameController = TextEditingController();
    final cityController = TextEditingController();
    final stateController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Bairro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Bairro',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: cityController,
              decoration: const InputDecoration(
                labelText: 'Cidade',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: stateController,
              decoration: const InputDecoration(
                labelText: 'Estado',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Motivo (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  cityController.text.isNotEmpty &&
                  stateController.text.isNotEmpty) {
                final neighborhood = ExcludedNeighborhood(
                  name: nameController.text,
                  city: cityController.text,
                  state: stateController.text,
                  addedAt: DateTime.now(),
                  reason: reasonController.text.isNotEmpty
                      ? reasonController.text
                      : null,
                );

                provider.addExcludedNeighborhood(neighborhood);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}
