import 'package:flutter/material.dart';
import '../../data/models/user_profile.dart';

/// Seção de preferências do usuário com switches organizados
class PreferencesSection extends StatelessWidget {

  const PreferencesSection({
    super.key,
    required this.preferences,
    required this.onPreferencesChanged,
    this.isEditing = true,
  });
  final UserPreferences preferences;
  final void Function(UserPreferences) onPreferencesChanged;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Preferências',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Seção de Notificações
            _buildSectionHeader(context, 'Notificações', Icons.notifications),
            const SizedBox(height: 8),
            _buildPreferenceSwitch(
              context: context,
              title: 'Notificações push',
              subtitle: 'Receber alertas sobre corridas e mensagens',
              value: preferences.notificationsEnabled,
              onChanged: isEditing ? (value) {
                onPreferencesChanged(
                  preferences.copyWith(notificationsEnabled: value),
                );
              } : null,
            ),
            _buildPreferenceSwitch(
              context: context,
              title: 'Sons',
              subtitle: 'Reproduzir sons de notificação',
              value: preferences.soundEnabled,
              onChanged: isEditing ? (value) {
                onPreferencesChanged(
                  preferences.copyWith(soundEnabled: value),
                );
              } : null,
            ),
            _buildPreferenceSwitch(
              context: context,
              title: 'Vibração',
              subtitle: 'Vibrar ao receber notificações',
              value: preferences.vibrationEnabled,
              onChanged: isEditing ? (value) {
                onPreferencesChanged(
                  preferences.copyWith(vibrationEnabled: value),
                );
              } : null,
            ),
            
            const Divider(height: 32),
            
            // Seção de Aparência
            _buildSectionHeader(context, 'Aparência', Icons.palette),
            const SizedBox(height: 8),
            _buildPreferenceSwitch(
              context: context,
              title: 'Modo escuro',
              subtitle: 'Usar tema escuro do aplicativo',
              value: preferences.darkModeEnabled,
              onChanged: isEditing ? (value) {
                onPreferencesChanged(
                  preferences.copyWith(darkModeEnabled: value),
                );
              } : null,
            ),
            
            const Divider(height: 32),
            
            // Seção de Privacidade
            _buildSectionHeader(context, 'Privacidade', Icons.privacy_tip),
            const SizedBox(height: 8),
            _buildPreferenceSwitch(
              context: context,
              title: 'Localização',
              subtitle: 'Permitir acesso à localização',
              value: preferences.locationEnabled,
              onChanged: isEditing ? (value) {
                onPreferencesChanged(
                  preferences.copyWith(locationEnabled: value),
                );
              } : null,
            ),
            
            const Divider(height: 32),
            
            // Seção de Localização/Idioma
            _buildSectionHeader(context, 'Regional', Icons.language),
            const SizedBox(height: 8),
            if (isEditing) ...[
              _buildLanguageSelector(context),
              const SizedBox(height: 12),
              _buildCurrencySelector(context),
            ] else ...[
              _buildInfoTile(
                context: context,
                title: 'Idioma',
                value: _getLanguageDisplayName(preferences.language),
                icon: Icons.translate,
              ),
              _buildInfoTile(
                context: context,
                title: 'Moeda',
                value: _getCurrencyDisplayName(preferences.currency),
                icon: Icons.attach_money,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferenceSwitch({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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

  Widget _buildLanguageSelector(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: preferences.language,
      decoration: InputDecoration(
        labelText: 'Idioma',
        prefixIcon: const Icon(Icons.translate),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'pt_BR', child: Text('Português (Brasil)')),
        DropdownMenuItem(value: 'en_US', child: Text('English (US)')),
        DropdownMenuItem(value: 'es_ES', child: Text('Español')),
      ],
      onChanged: isEditing ? (value) {
        if (value != null) {
          onPreferencesChanged(
            preferences.copyWith(language: value),
          );
        }
      } : null,
    );
  }

  Widget _buildCurrencySelector(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: preferences.currency,
      decoration: InputDecoration(
        labelText: 'Moeda',
        prefixIcon: const Icon(Icons.attach_money),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'BRL', child: Text('Real (R\$)')),
        DropdownMenuItem(value: 'USD', child: Text('Dólar (\$)')),
        DropdownMenuItem(value: 'EUR', child: Text('Euro (€)')),
      ],
      onChanged: isEditing ? (value) {
        if (value != null) {
          onPreferencesChanged(
            preferences.copyWith(currency: value),
          );
        }
      } : null,
    );
  }

  Widget _buildInfoTile({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'pt_BR':
        return 'Português (Brasil)';
      case 'en_US':
        return 'English (US)';
      case 'es_ES':
        return 'Español';
      default:
        return 'Português (Brasil)';
    }
  }

  String _getCurrencyDisplayName(String currencyCode) {
    switch (currencyCode) {
      case 'BRL':
        return 'Real (R\$)';
      case 'USD':
        return 'Dólar (\$)';
      case 'EUR':
        return 'Euro (€)';
      default:
        return 'Real (R\$)';
    }
  }
}

/// Widget compacto de preferências para outras telas
class CompactPreferences extends StatelessWidget {

  const CompactPreferences({
    super.key,
    required this.preferences,
    this.onTap,
  });
  final UserPreferences preferences;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.settings,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Preferências',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  if (onTap != null)
                    const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildCompactChip(
                    context,
                    preferences.notificationsEnabled ? 'Notificações On' : 'Notificações Off',
                    preferences.notificationsEnabled ? Colors.green : Colors.grey,
                  ),
                  _buildCompactChip(
                    context,
                    preferences.darkModeEnabled ? 'Modo Escuro' : 'Modo Claro',
                    preferences.darkModeEnabled ? Colors.indigo : Colors.orange,
                  ),
                  _buildCompactChip(
                    context,
                    preferences.locationEnabled ? 'Localização On' : 'Localização Off',
                    preferences.locationEnabled ? Colors.blue : Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}