import 'package:flutter/material.dart';

import 'labeled_field.dart';

typedef InputFieldValidator = String? Function(String value);

class ValidateLabeledField extends StatefulWidget {
  const ValidateLabeledField({
    required this.fieldKey,
    required this.label,
    required this.hintText,
    required this.controller,
    required this.validator,
    this.onChanged,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.onSubmitted,
    this.prefixIcon,
    this.isRequired = false,
    this.minLines,
    this.maxLines = 1,
    super.key,
  });

  final Key fieldKey;
  final String label;
  final String hintText;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final InputFieldValidator validator;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final String? prefixIcon;
  final bool isRequired;
  final int? minLines;
  final int? maxLines;

  @override
  State<ValidateLabeledField> createState() => _ValidateLabeledFieldState();
}

class _ValidateLabeledFieldState extends State<ValidateLabeledField> {
  late final FocusNode _focusNode;
  var _showValidation = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_handleFocusChanged);
  }

  void _handleFocusChanged() {
    if (!mounted) return;
    setState(() => _showValidation = !_focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LabeledField(
      fieldKey: widget.fieldKey,
      label: widget.label,
      hintText: widget.hintText,
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      prefixIcon: widget.prefixIcon,
      isRequired: widget.isRequired,
      errorText: _showValidation
          ? widget.validator(widget.controller.text)
          : null,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      onChanged: widget.onChanged,
    );
  }
}
