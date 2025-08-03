////
/// Página de Perfil
///
/// Propósito:
/// - Exibir dados do usuário, estatísticas, configurações e ações de conta.
///
/// Camadas/Dependências:
/// - Presentation da feature Profile. Somente UI e estado local.
///
/// Responsabilidades:
/// - Gerenciar preferências locais (notificações, tema, localização).
/// - Alternar modo motorista e ajustar taxa por km (estado local).
/// - Exibir menus de navegação informativos (placeholders).
///
/// Pontos de extensão:
/// - Integração com backend para persistir preferências e perfil.
/// - Navegação real para histórico, pagamentos e suporte.
///
/// Notas:
/// - Não altera assinaturas públicas nem lógica de negócio.
///
library;
import 'package:flutter/material.dart';

/// Página principal do perfil do usuário.
class ProfilePage extends StatefulWidget {
  /// Construtor padrão.
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Preferências locais simuladas para a UI.
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _locationEnabled = true;

  // Estado do modo motorista e taxa por km (apenas visual/local).
  bool _isDriverMode = false;

  // Taxa por km em R$ (meramente ilustrativo).
  double _driverRate = 2.5; // Taxa por km em R$

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editProfile, // Ação de edição (placeholder).
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildStatsCard(),
            const SizedBox(height: 24),
            _buildDriverSection(),
            const SizedBox(height: 24),
            _buildSettingsSection(),
            const SizedBox(height: 24),
            _buildMenuSection(),
          ],
        ),
      ),
    );
  }

  /// Cabeçalho do perfil com avatar, nome, e e-mail.
  Widget _buildProfileHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'João Silva',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'joao.silva@email.com',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, color: Colors.green[600], size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Usuário Verificado',
                    style: TextStyle(
                      color: Colors.green[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card de estatísticas agregadas do usuário (mock).
  Widget _buildStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estatísticas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.directions_bus,
                    value: '127',
                    label: 'Viagens',
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.eco,
                    value: '45kg',
                    label: 'CO₂ Economizado',
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.access_time,
                    value: '32h',
                    label: 'Tempo Total',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Item de estatística visual com ícone, valor e rótulo.
  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Seção do modo motorista com controle de taxa por quilômetro.
  /// Efeitos colaterais: atualiza estado local ao alternar modo/ajustar taxa.
  Widget _buildDriverSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.drive_eta,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Modo Motorista',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                Switch(
                  value: _isDriverMode,
                  onChanged: (value) {
                    setState(() {
                      _isDriverMode = value;
                    });
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
            if (_isDriverMode) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          color: Colors.blue[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Minha Taxa por Quilômetro',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'R\$ ${_driverRate.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const Text(' / km'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Theme.of(context).primaryColor,
                        inactiveTrackColor: Colors.grey[300],
                        thumbColor: Theme.of(context).primaryColor,
                        overlayColor: Theme.of(context).primaryColor.withOpacity(0.2),
                        valueIndicatorColor: Theme.of(context).primaryColor,
                        valueIndicatorTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Slider(
                        value: _driverRate,
                        min: 1.0,
                        max: 5.0,
                        divisions: 40,
                        label: 'R\$ ${_driverRate.toStringAsFixed(2)}',
                        onChanged: (value) {
                          setState(() {
                            _driverRate = value;
                          });
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'R\$ 1,00',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'R\$ 5,00',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.green[700],
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Esta será sua taxa base. Passageiros verão o valor estimado antes de solicitar a corrida.',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Seção de configurações com toggles (notificações, tema, localização).
  Widget _buildSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configurações',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              icon: Icons.notifications,
              title: 'Notificações',
              subtitle: 'Receber alertas de transporte',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            _buildSwitchTile(
              icon: Icons.dark_mode,
              title: 'Modo Escuro',
              subtitle: 'Tema escuro do aplicativo',
              value: _darkModeEnabled,
              onChanged: (value) {
                setState(() {
                  _darkModeEnabled = value;
                });
              },
            ),
            _buildSwitchTile(
              icon: Icons.location_on,
              title: 'Localização',
              subtitle: 'Permitir acesso à localização',
              value: _locationEnabled,
              onChanged: (value) {
                setState(() {
                  _locationEnabled = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Tile reutilizável para switches de configuração.
  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  /// Seção de menu com navegações (placeholders).
  Widget _buildMenuSection() {
    return Card(
      child: Column(
        children: [
          _buildMenuTile(
            icon: Icons.history,
            title: 'Histórico de Viagens',
            onTap: () => _showComingSoon('Histórico de Viagens'),
          ),
          _buildMenuTile(
            icon: Icons.payment,
            title: 'Métodos de Pagamento',
            onTap: () => _showComingSoon('Métodos de Pagamento'),
          ),
          _buildMenuTile(
            icon: Icons.help,
            title: 'Ajuda e Suporte',
            onTap: () => _showComingSoon('Ajuda e Suporte'),
          ),
          _buildMenuTile(
            icon: Icons.info,
            title: 'Sobre o App',
            onTap: _showAbout,
          ),
          _buildMenuTile(
            icon: Icons.logout,
            title: 'Sair',
            onTap: _logout,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  /// Tile de menu genérico com ícone, título e ação.
  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Theme.of(context).primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  /// Placeholder para ação de editar perfil.
  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: const Text('Funcionalidade de edição será implementada em breve.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Exibe um SnackBar informando que a funcionalidade virá em breve.
  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Em breve!'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  /// Exibe diálogo "Sobre".
  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Urban Mobility',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.directions_bus,
        size: 48,
        color: Theme.of(context).primaryColor,
      ),
      children: [
        const Text(
          'App de mobilidade urbana para transporte inteligente. '
          'Encontre as melhores rotas, horários de transporte público '
          'e opções de mobilidade sustentável.',
        ),
      ],
    );
  }

  /// Confirmação e feedback de logout (placeholder sem integração).
  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair do aplicativo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implementar logout
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logout realizado com sucesso!'),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}