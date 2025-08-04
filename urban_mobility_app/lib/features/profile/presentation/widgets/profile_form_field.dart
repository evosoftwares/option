import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Campo de formulário especializado para perfil com debounce e validação
class ProfileFormField extends StatefulWidget {

  const ProfileFormField({
    super.key,
    required this.label,
    this.initialValue,
    this.hintText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.focusNode,
    this.controller,
    this.showCharacterCount = false,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.autofocus = false,
  });
  final String label;
  final String? initialValue;
  final String? hintText;
  final String? helperText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final bool showCharacterCount;
  final Duration debounceDuration;
  final bool autofocus;

  @override
  State<ProfileFormField> createState() => _ProfileFormFieldState();
}

class _ProfileFormFieldState extends State<ProfileFormField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  Timer? _debounceTimer;
  String? _errorText;
  bool _isValidating = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _validateField();
    }
  }

  void _onTextChanged(String value) {
    _debounceTimer?.cancel();
    
    if (widget.onChanged != null) {
      _debounceTimer = Timer(widget.debounceDuration, () {
        widget.onChanged!(value);
      });
    }

    // Validação em tempo real apenas para erros críticos
    if (_errorText != null) {
      _validateField();
    }
  }

  void _validateField() {
    if (widget.validator != null) {
      setState(() {
        _isValidating = true;
      });

      // Simular validação assíncrona se necessário
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _errorText = widget.validator!(_controller.text);
            _isValidating = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          onChanged: _onTextChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          autofocus: widget.autofocus,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hintText,
            helperText: widget.helperText,
            errorText: _errorText,
            prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
            suffixIcon: _buildSuffixIcon(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            counterText: widget.showCharacterCount ? null : '',
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (_isValidating) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_errorText != null) {
      return Icon(
        Icons.error_outline,
        color: Theme.of(context).colorScheme.error,
      );
    }

    if (_controller.text.isNotEmpty && _errorText == null && widget.validator != null) {
      return Icon(
        Icons.check_circle_outline,
        color: Colors.green[600],
      );
    }

    return widget.suffixIcon;
  }
}

/// Campo específico para telefone com formatação automática
class PhoneFormField extends StatelessWidget {

  const PhoneFormField({
    super.key,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.focusNode,
    this.autofocus = false,
  });
  final String? initialValue;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return ProfileFormField(
      label: 'Telefone',
      initialValue: initialValue,
      hintText: '(11) 99999-9999',
      prefixIcon: Icons.phone,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _PhoneInputFormatter(),
      ],
      validator: validator ?? _defaultPhoneValidator,
      onChanged: onChanged,
      focusNode: focusNode,
      autofocus: autofocus,
    );
  }

  String? _defaultPhoneValidator(String? value) {
    if (value == null || value.isEmpty) return null;
    
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 10 || digitsOnly.length > 11) {
      return 'Telefone deve ter 10 ou 11 dígitos';
    }
    return null;
  }
}

/// Campo específico para CPF com formatação e validação
class CPFFormField extends StatelessWidget {

  const CPFFormField({
    super.key,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.focusNode,
    this.autofocus = false,
  });
  final String? initialValue;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return ProfileFormField(
      label: 'CPF',
      initialValue: initialValue,
      hintText: '000.000.000-00',
      prefixIcon: Icons.badge_outlined,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _CPFInputFormatter(),
      ],
      validator: validator ?? _defaultCPFValidator,
      onChanged: onChanged,
      focusNode: focusNode,
      autofocus: autofocus,
    );
  }

  String? _defaultCPFValidator(String? value) {
    if (value == null || value.isEmpty) return null;
    
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }
    
    // Validação básica de CPF
    if (!_isValidCPF(digitsOnly)) {
      return 'CPF inválido';
    }
    
    return null;
  }

  bool _isValidCPF(String cpf) {
    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) return false;

    // Calcula os dígitos verificadores
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cpf[i]) * (10 - i);
    }
    int firstDigit = (sum * 10) % 11;
    if (firstDigit == 10) firstDigit = 0;

    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cpf[i]) * (11 - i);
    }
    int secondDigit = (sum * 10) % 11;
    if (secondDigit == 10) secondDigit = 0;

    return cpf[9] == firstDigit.toString() && cpf[10] == secondDigit.toString();
  }
}

/// Formatter para telefone brasileiro
class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String formatted = '';
    
    if (text.length <= 2) {
      formatted = '($text';
    } else if (text.length <= 6) {
      formatted = '(${text.substring(0, 2)}) ${text.substring(2)}';
    } else if (text.length <= 10) {
      formatted = '(${text.substring(0, 2)}) ${text.substring(2, 6)}-${text.substring(6)}';
    } else {
      formatted = '(${text.substring(0, 2)}) ${text.substring(2, 7)}-${text.substring(7, 11)}';
    }

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatter para CPF brasileiro
class _CPFInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String formatted = '';
    
    if (text.length <= 3) {
      formatted = text;
    } else if (text.length <= 6) {
      formatted = '${text.substring(0, 3)}.${text.substring(3)}';
    } else if (text.length <= 9) {
      formatted = '${text.substring(0, 3)}.${text.substring(3, 6)}.${text.substring(6)}';
    } else {
      formatted = '${text.substring(0, 3)}.${text.substring(3, 6)}.${text.substring(6, 9)}-${text.substring(9, 11)}';
    }

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}