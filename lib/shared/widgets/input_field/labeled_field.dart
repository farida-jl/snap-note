import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_theme.dart';

class LabeledField extends StatelessWidget {
  const LabeledField({
    required this.fieldKey,
    required this.label,
    required this.hintText,
    required this.controller,
    required this.onChanged,
    this.focusNode,
    this.keyboardType,
    this.prefixIcon,
    this.errorText,
    this.isRequired = false,
    this.minLines,
    this.maxLines = 1,
    super.key,
  });

  final Key fieldKey;
  final String label;
  final String hintText;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final String? prefixIcon;
  final String? errorText;
  final bool isRequired;
  final int? minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: isRequired ? '$label, required' : label,
          excludeSemantics: true,
          child: Text.rich(
            TextSpan(
              text: label,
              children: [
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.appColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          key: fieldKey,
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          minLines: minLines,
          maxLines: maxLines,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: context.appColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            hintStyle: TextStyle(
              fontSize: 14,
              color: context.appColors.textSecondary,
            ),
            prefixIcon: prefixIcon == null
                ? null
                : Padding(
                    padding: const EdgeInsets.fromLTRB(14, 16, 10, 16),
                    child: SvgPicture.asset(
                      prefixIcon!,
                      width: 18,
                      height: 18,
                      colorFilter: ColorFilter.mode(
                        context.appColors.textSecondary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
            prefixIconConstraints: const BoxConstraints(minWidth: 42),
            filled: true,
            fillColor: context.appColors.card,
            contentPadding: const EdgeInsets.all(14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.appColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.appColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
