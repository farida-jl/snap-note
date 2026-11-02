import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:snap_note/shared/widgets/navigation_bar/standart_bav_bar.dart';

import '../../../../core/theme/app_theme.dart';
import '../bloc/pocket_link_bloc.dart';

class PocketLinkPage extends StatefulWidget {
  const PocketLinkPage({super.key});

  @override
  State<PocketLinkPage> createState() => _PocketLinkPageState();
}

class _PocketLinkPageState extends State<PocketLinkPage> {
  late final TextEditingController _urlController;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final state = context.read<PocketLinkBloc>().state;
    _urlController = TextEditingController(text: state.url);
    _titleController = TextEditingController(text: state.title);
    _descriptionController = TextEditingController(text: state.description);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PocketLinkBloc, PocketLinkState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == PocketLinkStatus.success) {
          Navigator.of(context).pop(true);
        } else if (state.status == PocketLinkStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Could not save link.'),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              const StandartNavigationBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child: BlocBuilder<PocketLinkBloc, PocketLinkState>(
                    buildWhen: (previous, current) =>
                        previous.url != current.url ||
                        previous.sourceHost != current.sourceHost,
                    builder: (context, state) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Introduction(),
                        const SizedBox(height: 22),
                        _LabeledField(
                          fieldKey: const ValueKey('pocket-link-url-field'),
                          label: 'Link URL',
                          hintText: 'https://example.com/article',
                          controller: _urlController,
                          keyboardType: TextInputType.url,
                          maxLines: 2,
                          minLines: 1,
                          prefixIcon: 'assets/icons/link.svg',
                          onChanged: (value) => context
                              .read<PocketLinkBloc>()
                              .add(PocketLinkUrlChanged(value)),
                        ),
                        const SizedBox(height: 22),
                        if (state.uri != null) ...[
                          _FetchedPreview(host: state.sourceHost),
                          const SizedBox(height: 22),
                        ],
                        _LabeledField(
                          fieldKey: const ValueKey('pocket-link-title-field'),
                          label: 'Title',
                          hintText: 'Give this link a title',
                          controller: _titleController,
                          onChanged: (value) => context
                              .read<PocketLinkBloc>()
                              .add(PocketLinkTitleChanged(value)),
                        ),
                        const SizedBox(height: 22),
                        _LabeledField(
                          fieldKey: const ValueKey(
                            'pocket-link-description-field',
                          ),
                          label: 'Description',
                          hintText: 'Why do you want to keep this?',
                          controller: _descriptionController,
                          minLines: 3,
                          maxLines: 5,
                          onChanged: (value) => context
                              .read<PocketLinkBloc>()
                              .add(PocketLinkDescriptionChanged(value)),
                        ),
                        const SizedBox(height: 20),
                        const _CollectionAssignment(),
                      ],
                    ),
                  ),
                ),
              ),
              const _SaveActions(),
            ],
          ),
        ),
      ),
    );
  }
}


class _Introduction extends StatelessWidget {
  const _Introduction();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.subtle,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset('assets/icons/link.svg', width: 13, height: 13),
              const SizedBox(width: 5),
              const Text(
                'POCKET LINK',
                style: TextStyle(
                  fontSize: 10,
                  height: 1.1,
                  fontWeight: FontWeight.w600,
                  letterSpacing: .8,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'A good find, kept close.',
          style: TextStyle(
            fontFamily: 'Lora',
            fontSize: 29,
            height: 1.15,
            letterSpacing: -.7,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Save a link with a little context for future you.',
          style: TextStyle(
            fontSize: 13,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.fieldKey,
    required this.label,
    required this.hintText,
    required this.controller,
    required this.onChanged,
    this.keyboardType,
    this.prefixIcon,
    this.minLines,
    this.maxLines = 1,
  });

  final Key fieldKey;
  final String label;
  final String hintText;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final String? prefixIcon;
  final int? minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          key: fieldKey,
          controller: controller,
          keyboardType: keyboardType,
          minLines: minLines,
          maxLines: maxLines,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            prefixIcon: prefixIcon == null
                ? null
                : Padding(
                    padding: const EdgeInsets.fromLTRB(14, 16, 10, 16),
                    child: SvgPicture.asset(
                      prefixIcon!,
                      width: 18,
                      height: 18,
                      colorFilter: const ColorFilter.mode(
                        AppColors.textSecondary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
            prefixIconConstraints: const BoxConstraints(minWidth: 42),
            filled: true,
            fillColor: AppColors.card,
            contentPadding: const EdgeInsets.all(14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class _FetchedPreview extends StatelessWidget {
  const _FetchedPreview({required this.host});

  final String host;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.subtle,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgPicture.asset(
              'assets/icons/book_open.svg',
              width: 23,
              height: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  host,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Article · 8 min read',
                  style: TextStyle(fontSize: 11, color: AppColors.primary),
                ),
              ],
            ),
          ),
          SvgPicture.asset(
            'assets/icons/pocket_link_valid.svg',
            width: 18,
            height: 18,
          ),
        ],
      ),
    );
  }
}

class _CollectionAssignment extends StatelessWidget {
  const _CollectionAssignment();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saved to collection',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          key: const ValueKey('pocket-link-collection-assignment'),
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.subtle,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/icons/folders.svg',
                  width: 23,
                  height: 23,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Read Later',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.primary,
                  size: 24.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SaveActions extends StatelessWidget {
  const _SaveActions();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PocketLinkBloc, PocketLinkState>(
      buildWhen: (previous, current) =>
          previous.isValid != current.isValid ||
          previous.status != current.status,
      builder: (context, state) {
        final isSaving = state.status == PocketLinkStatus.saving;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
          color: AppColors.background,
          child: Column(
            children: [
              const Text(
                'Find it later by title, link, or your description.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: state.isValid && !isSaving
                      ? () => context.read<PocketLinkBloc>().add(
                          const PocketLinkSubmitted(),
                        )
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    disabledBackgroundColor: AppColors.accent.withValues(
                      alpha: .45,
                    ),
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textPrimary,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/pocket_link_check.svg',
                              width: 19,
                              height: 19,
                            ),
                            const SizedBox(width: 9),
                            const Text(
                              'Save pocket link',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
