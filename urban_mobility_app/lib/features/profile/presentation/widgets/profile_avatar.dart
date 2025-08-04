import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// Widget de avatar de perfil com funcionalidade de edição
class ProfileAvatar extends StatefulWidget {

  const ProfileAvatar({
    super.key,
    this.avatarUrl,
    required this.fallbackText,
    this.size = 100,
    this.isEditable = false,
    this.onImageSelected,
    this.onRemoveImage,
    this.isLoading = false,
    this.heroTag,
  });
  final String? avatarUrl;
  final String fallbackText;
  final double size;
  final bool isEditable;
  final Function(File)? onImageSelected;
  final VoidCallback? onRemoveImage;
  final bool isLoading;
  final String? heroTag;

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatar = widget.heroTag != null
        ? Hero(
            tag: widget.heroTag!,
            child: _buildAvatar(),
          )
        : _buildAvatar();

    if (!widget.isEditable) {
      return avatar;
    }

    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: _showImageOptions,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              children: [
                avatar,
                if (widget.isLoading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty
            ? Image.network(
                widget.avatarUrl!,
                width: widget.size,
                height: widget.size,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallbackAvatar();
                },
              )
            : _buildFallbackAvatar(),
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          _getInitials(widget.fallbackText),
          style: TextStyle(
            color: Colors.white,
            fontSize: widget.size * 0.3,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '?';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tirar foto'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Escolher da galeria'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (widget.avatarUrl != null && widget.onRemoveImage != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remover foto', 
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmRemoveImage();
                },
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null && widget.onImageSelected != null) {
        final file = File(image.path);
        
        // Verificar tamanho do arquivo (max 5MB)
        final fileSizeInBytes = await file.length();
        const maxSizeInBytes = 5 * 1024 * 1024; // 5MB
        
        if (fileSizeInBytes > maxSizeInBytes) {
          if (mounted) {
            _showError('A imagem deve ter no máximo 5MB');
          }
          return;
        }

        widget.onImageSelected!(file);
        
        // Feedback tátil
        if (mounted) {
          HapticFeedback.lightImpact();
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Erro ao selecionar imagem: ${e.toString()}');
      }
    }
  }

  void _confirmRemoveImage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover foto'),
        content: const Text(
          'Tem certeza que deseja remover sua foto de perfil?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onRemoveImage?.call();
              HapticFeedback.lightImpact();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Widget de avatar simples apenas para exibição
class SimpleAvatar extends StatelessWidget {

  const SimpleAvatar({
    super.key,
    this.avatarUrl,
    required this.fallbackText,
    this.size = 40,
    this.heroTag,
  });
  final String? avatarUrl;
  final String fallbackText;
  final double size;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final avatar = ProfileAvatar(
      avatarUrl: avatarUrl,
      fallbackText: fallbackText,
      size: size,
      isEditable: false,
      heroTag: heroTag,
    );

    return avatar;
  }
}

/// Indicador de status online para avatar
class AvatarWithStatus extends StatelessWidget {

  const AvatarWithStatus({
    super.key,
    this.avatarUrl,
    required this.fallbackText,
    this.size = 40,
    this.isOnline = false,
    this.heroTag,
  });
  final String? avatarUrl;
  final String fallbackText;
  final double size;
  final bool isOnline;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SimpleAvatar(
          avatarUrl: avatarUrl,
          fallbackText: fallbackText,
          size: size,
          heroTag: heroTag,
        ),
        if (isOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: size * 0.25,
              height: size * 0.25,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}