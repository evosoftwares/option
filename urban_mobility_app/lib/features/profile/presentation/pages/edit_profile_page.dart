import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/profile_edit_provider.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_form_field.dart';
import '../widgets/preferences_section.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/profile_draft.dart';

/// Tela de edição de perfil com modo de edição unificado
class EditProfilePage extends StatefulWidget {

  const EditProfilePage({
    super.key,
    this.initialProfile,
    this.initialSection = ProfileSection.basic,
  });
  final UserProfile? initialProfile;
  final ProfileSection initialSection;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  late ProfileEditProvider _provider;
  
  final List<FocusNode> _focusNodes = [];
  final List<TextEditingController> _controllers = [];
  
  bool _hasUnsavedChanges = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    
    _provider = Provider.of<ProfileEditProvider>(context, listen: false);
    
    final initialTab = _getTabIndex(widget.initialSection);
    _tabController = TabController(
      length: 3, // basic, preferences, passenger
      vsync: this,
      initialIndex: initialTab,
    );
    
    _pageController = PageController(initialPage: initialTab);
    
    // Inicializar controladores de texto
    _initializeControllers();
    
    // Carregar perfil inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialProfile != null) {
        _provider.loadProfile(widget.initialProfile!);
      }
    });
    
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _pageController.animateToPage(
          _tabController.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    for (final node in _focusNodes) {
      node.dispose();
    }
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeControllers() {
    // Controllers para campos básicos
    for (int i = 0; i < 6; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
  }

  int _getTabIndex(ProfileSection section) {
    switch (section) {
      case ProfileSection.basic:
        return 0;
      case ProfileSection.preferences:
        return 1;
      case ProfileSection.passenger:
        return 2;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvoked: (didPop) async {
        if (!didPop && _hasUnsavedChanges) {
          final shouldPop = await _showUnsavedChangesDialog();
          if (shouldPop == true && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Consumer<ProfileEditProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: _buildAppBar(provider),
            body: _buildBody(provider),
            bottomNavigationBar: _buildBottomBar(provider),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ProfileEditProvider provider) {
    return AppBar(
      title: Text(_isEditMode ? 'Editar Perfil' : 'Meu Perfil'),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        if (!_isEditMode)
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _toggleEditMode(true),
            tooltip: 'Editar perfil',
          ),
        if (_isEditMode) ...[
          if (provider.hasUnsavedChanges)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: provider.isSaving ? null : () => _saveProfile(provider),
              tooltip: 'Salvar alterações',
            ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _toggleEditMode(false),
            tooltip: 'Cancelar edição',
          ),
        ],
      ],
      bottom: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
        tabs: const [
          Tab(text: 'Básico', icon: Icon(Icons.person)),
          Tab(text: 'Preferências', icon: Icon(Icons.settings)),
          Tab(text: 'Passageiro', icon: Icon(Icons.directions_walk)),
        ],
      ),
    );
  }

  Widget _buildBody(ProfileEditProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar perfil',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              provider.error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => provider.retry(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        _tabController.animateTo(index);
      },
      children: [
        _buildBasicInfoPage(provider),
        _buildPreferencesPage(provider),
        _buildPassengerPage(provider),
      ],
    );
  }

  Widget _buildBasicInfoPage(ProfileEditProvider provider) {
    final profile = provider.currentProfile;
    if (profile == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Avatar
          ProfileAvatar(
            avatarUrl: profile.avatarUrl,
            fallbackText: profile.displayName,
            size: 120,
            isEditable: _isEditMode,
            isLoading: provider.isUploadingAvatar,
            onImageSelected: (file) => _uploadAvatar(provider, file),
            onRemoveImage: () => _removeAvatar(provider),
            heroTag: 'profile_avatar',
          ),
          
          const SizedBox(height: 24),
          
          // Informações básicas
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informações Básicas',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  ProfileFormField(
                    label: 'Nome',
                    initialValue: profile.firstName,
                    enabled: _isEditMode,
                    prefixIcon: Icons.person,
                    validator: (value) => _validateName(value, 'Nome'),
                    onChanged: (value) => _updateField(provider, ProfileSection.basic, 'firstName', value),
                    autofocus: _isEditMode,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  ProfileFormField(
                    label: 'Sobrenome',
                    initialValue: profile.lastName,
                    enabled: _isEditMode,
                    prefixIcon: Icons.person_outline,
                    validator: (value) => _validateName(value, 'Sobrenome'),
                    onChanged: (value) => _updateField(provider, ProfileSection.basic, 'lastName', value),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  ProfileFormField(
                    label: 'Email',
                    initialValue: profile.email,
                    enabled: false, // Email não pode ser editado
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  PhoneFormField(
                    initialValue: profile.phone,
                    onChanged: _isEditMode ? (value) => _updateField(provider, ProfileSection.basic, 'phone', value) : null,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  ProfileFormField(
                    label: 'Bio',
                    initialValue: profile.bio,
                    enabled: _isEditMode,
                    prefixIcon: Icons.info_outline,
                    hintText: 'Conte um pouco sobre você',
                    maxLines: 3,
                    maxLength: 200,
                    showCharacterCount: _isEditMode,
                    onChanged: (value) => _updateField(provider, ProfileSection.basic, 'bio', value),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildDateField(
                    context: context,
                    label: 'Data de Nascimento',
                    value: profile.dateOfBirth,
                    enabled: _isEditMode,
                    onChanged: (date) => _updateField(provider, ProfileSection.basic, 'dateOfBirth', date?.toIso8601String()),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Status de verificação
          _buildVerificationCard(profile),
        ],
      ),
    );
  }

  Widget _buildPreferencesPage(ProfileEditProvider provider) {
    final profile = provider.currentProfile;
    if (profile == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PreferencesSection(
        preferences: profile.preferences,
        isEditing: _isEditMode,
        onPreferencesChanged: (prefs) => _updatePreferences(provider, prefs),
      ),
    );
  }

  Widget _buildPassengerPage(ProfileEditProvider provider) {
    final profile = provider.currentProfile;
    if (profile == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.directions_walk,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Dados do Passageiro',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  ProfileFormField(
                    label: 'Contato de Emergência',
                    initialValue: profile.passengerProfile?.emergencyContactName,
                    enabled: _isEditMode,
                    prefixIcon: Icons.emergency,
                    hintText: 'Nome do contato',
                    onChanged: (value) => _updatePassengerField(provider, 'emergencyContactName', value),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  PhoneFormField(
                    initialValue: profile.passengerProfile?.emergencyContactPhone,
                    onChanged: _isEditMode ? (value) => _updatePassengerField(provider, 'emergencyContactPhone', value) : null,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  ProfileFormField(
                    label: 'Método de Pagamento Preferido',
                    initialValue: profile.passengerProfile?.paymentMethod,
                    enabled: _isEditMode,
                    prefixIcon: Icons.payment,
                    hintText: 'Ex: Cartão, PIX, Dinheiro',
                    onChanged: (value) => _updatePassengerField(provider, 'paymentMethod', value),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Estatísticas do passageiro
          _buildPassengerStats(profile),
        ],
      ),
    );
  }

  Widget _buildVerificationCard(UserProfile profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.verified_user,
                  color: profile.isVerified ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  'Status de Verificação',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (profile.isVerified ? Colors.green : Colors.orange).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (profile.isVerified ? Colors.green : Colors.orange).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    profile.isVerified ? Icons.check_circle : Icons.schedule,
                    color: profile.isVerified ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      profile.isVerified 
                          ? 'Perfil verificado'
                          : 'Verificação pendente',
                      style: TextStyle(
                        color: profile.isVerified ? Colors.green[700] : Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildPassengerStats(UserProfile profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suas Estatísticas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.directions_car,
                    value: '${profile.stats.totalRides}',
                    label: 'Corridas',
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.eco,
                    value: '${profile.stats.co2Saved.toStringAsFixed(1)}kg',
                    label: 'CO₂ Economizado',
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.star,
                    value: profile.stats.averageRating.toStringAsFixed(1),
                    label: 'Avaliação',
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

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required DateTime? value,
    required bool enabled,
    required void Function(DateTime?) onChanged,
  }) {
    return ProfileFormField(
      label: label,
      initialValue: value?.toLocal().toString().split(' ')[0],
      enabled: enabled,
      readOnly: true,
      prefixIcon: Icons.calendar_today,
      onTap: enabled ? () => _selectDate(context, value, onChanged) : null,
    );
  }

  Widget _buildBottomBar(ProfileEditProvider provider) {
    if (!_isEditMode || !provider.hasUnsavedChanges) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (provider.lastSavedAt != null)
              Expanded(
                child: Text(
                  'Salvo automaticamente em ${_formatSaveTime(provider.lastSavedAt!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green[600],
                  ),
                ),
              ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: provider.isSaving ? null : () => _saveProfile(provider),
              icon: provider.isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(provider.isSaving ? 'Salvando...' : 'Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleEditMode(bool editMode) {
    setState(() {
      _isEditMode = editMode;
    });
    
    if (!editMode) {
      // Cancelar edição - descartar mudanças
      _provider.discardChanges();
      _unfocusAll();
    }
  }

  void _updateField(ProfileEditProvider provider, ProfileSection section, String field, String? value) {
    provider.updateField(section, field, value);
    setState(() {
      _hasUnsavedChanges = provider.hasUnsavedChanges;
    });
  }

  void _updatePreferences(ProfileEditProvider provider, UserPreferences preferences) {
    provider.updatePreferences(preferences);
    setState(() {
      _hasUnsavedChanges = provider.hasUnsavedChanges;
    });
  }

  void _updatePassengerField(ProfileEditProvider provider, String field, String? value) {
    provider.updatePassengerField(field, value);
    setState(() {
      _hasUnsavedChanges = provider.hasUnsavedChanges;
    });
  }

  Future<void> _uploadAvatar(ProfileEditProvider provider, File file) async {
    try {
      await provider.uploadAvatar(file);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto de perfil atualizada!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar foto: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _removeAvatar(ProfileEditProvider provider) async {
    try {
      await provider.removeAvatar();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto de perfil removida!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover foto: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile(ProfileEditProvider provider) async {
    try {
      await provider.saveProfile();
      setState(() {
        _hasUnsavedChanges = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar perfil: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context, DateTime? initialDate, void Function(DateTime?) onChanged) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 100);
    final lastDate = DateTime(now.year - 16);

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? lastDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Selecionar data de nascimento',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );

    if (date != null) {
      onChanged(date);
    }
  }

  Future<bool?> _showUnsavedChangesDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterações não salvas'),
        content: const Text(
          'Você tem alterações não salvas. Deseja sair sem salvar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continuar editando'),
          ),
          TextButton(
            onPressed: () {
              _provider.discardChanges();
              Navigator.pop(context, true);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sair sem salvar'),
          ),
        ],
      ),
    );
  }

  String? _validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName é obrigatório';
    }
    if (value.trim().length < 2) {
      return '$fieldName deve ter pelo menos 2 caracteres';
    }
    if (value.length > 50) {
      return '$fieldName deve ter no máximo 50 caracteres';
    }
    return null;
  }

  String _formatSaveTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'agora mesmo';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}min atrás';
    } else {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  void _unfocusAll() {
    for (final node in _focusNodes) {
      node.unfocus();
    }
  }
}