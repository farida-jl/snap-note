import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:snap_note/shared/widgets/input_field/input_field.dart';
import 'package:snap_note/shared/widgets/navigation_bar/standart_nav_bar.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/collection_assignment.dart';
import '../../../collections/domain/entities/folio_collection.dart';
import '../../../collections/presentation/bloc/collections_bloc.dart';
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
    final collections = context.watch<CollectionsBloc>().state.collections;

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
        backgroundColor: context.appColors.background,
        body: SafeArea(
          child: Column(
            children: [
              StandartNavigationBar(title: 'Create pocket link'),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child: BlocBuilder<PocketLinkBloc, PocketLinkState>(
                    buildWhen: (previous, current) =>
                        previous.url != current.url ||
                        previous.sourceHost != current.sourceHost ||
                        previous.collectionId != current.collectionId,
                    builder: (context, state) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Introduction(),
                        const SizedBox(height: 22),
                        ValidateLabeledField(
                          fieldKey: const ValueKey('pocket-link-url-field'),
                          label: 'Link URL',
                          hintText: 'https://example.com/article',
                          controller: _urlController,
                          keyboardType: TextInputType.url,
                          maxLines: 4,
                          minLines: 1,
                          prefixIcon: 'assets/icons/link.svg',
                          isRequired: true,
                          validator: _validateUrl,
                          onChanged: (value) => context
                              .read<PocketLinkBloc>()
                              .add(PocketLinkUrlChanged(value)),
                        ),
                        const SizedBox(height: 22),
                        LabeledField(
                          fieldKey: const ValueKey('pocket-link-title-field'),
                          label: 'Title',
                          hintText: 'Give this link a title',
                          controller: _titleController,
                          isRequired: true,
                          onChanged: (value) => context
                              .read<PocketLinkBloc>()
                              .add(PocketLinkTitleChanged(value)),
                        ),
                        const SizedBox(height: 22),
                        LabeledField(
                          fieldKey: const ValueKey(
                            'pocket-link-description-field',
                          ),
                          label: 'Description',
                          hintText: 'Why do you want to keep this?',
                          controller: _descriptionController,
                          isRequired: false,
                          minLines: 3,
                          maxLines: 5,
                          onChanged: (value) => context
                              .read<PocketLinkBloc>()
                              .add(PocketLinkDescriptionChanged(value)),
                        ),
                        const SizedBox(height: 20),
                        CollectionAssignment(
                          assignmentKey: const ValueKey(
                            'pocket-link-collection-assignment',
                          ),
                          selectedCollection: _selectedCollection(
                            collections,
                            state.collectionId,
                          ),
                          collections: collections,
                          onSelected: (collection) => context
                              .read<PocketLinkBloc>()
                              .add(PocketLinkCollectionChanged(collection.id)),
                        ),
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

  String? _validateUrl(String value) {
    if (value.isEmpty) return null;

    final uri = Uri.tryParse(value.trim());
    final isValid =
        uri != null &&
        uri.hasScheme &&
        {'http', 'https'}.contains(uri.scheme) &&
        uri.host.isNotEmpty;
    return isValid ? null : 'Enter a valid URL, such as https://example.com.';
  }

  FolioCollection? _selectedCollection(
    List<FolioCollection> collections,
    int? selectedCollectionId,
  ) {
    for (final collection in collections) {
      if (collection.id == selectedCollectionId) return collection;
    }
    for (final collection in collections) {
      if (collection.title == 'Read Later') return collection;
    }
    return null;
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
            color: context.appColors.subtle,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/icons/link.svg',
                width: 13,
                height: 13,
                colorFilter: ColorFilter.mode(
                  context.appColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'POCKET LINK',
                style: TextStyle(
                  fontSize: 10,
                  height: 1.1,
                  fontWeight: FontWeight.w600,
                  letterSpacing: .8,
                  color: context.appColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'A good find, kept close.',
          style: TextStyle(
            fontFamily: 'Lora',
            fontSize: 29,
            height: 1.15,
            letterSpacing: -.7,
            color: context.appColors.primary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Save a link with a little context for future you.',
          style: TextStyle(
            fontSize: 13,
            height: 1.6,
            color: context.appColors.textSecondary,
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
          color: context.appColors.background,
          child: Column(
            children: [
              Text(
                'Find it later by title, link, or your description.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: context.appColors.textSecondary,
                ),
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
                    backgroundColor: context.appColors.accent,
                    disabledBackgroundColor: context.appColors.accent
                        .withValues(alpha: .45),
                    foregroundColor: context.appColors.onAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSaving
                      ? SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.appColors.onAccent,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/pocket_link_check.svg',
                              width: 19,
                              height: 19,
                              colorFilter: ColorFilter.mode(
                                context.appColors.onAccent,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 9),
                            Text(
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
