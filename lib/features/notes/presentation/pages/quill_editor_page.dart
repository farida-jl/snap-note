import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../../core/theme/app_theme.dart';

class QuillEditorExamplePage extends StatefulWidget {
  const QuillEditorExamplePage({super.key});

  @override
  State<QuillEditorExamplePage> createState() => _QuillEditorExamplePageState();
}

class _QuillEditorExamplePageState extends State<QuillEditorExamplePage> {
  late final QuillController _controller;
  late final FocusNode _editorFocusNode;
  late final ScrollController _editorScrollController;

  String? _deltaJson;

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();
    _editorFocusNode = FocusNode();
    _editorScrollController = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: QuillEditorPage(
                  controller: _controller,
                  focusNode: _editorFocusNode,
                  scrollController: _editorScrollController,
                  toolbarKey: const ValueKey('quill-example-toolbar'),
                  editorKey: const ValueKey('quill-example-editor'),
                ),
            ),
            if (_deltaJson case final deltaJson?)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.subtle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  deltaJson,
                  key: const ValueKey('quill-example-delta'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class QuillEditorPage extends StatelessWidget {
  const QuillEditorPage({
    required this.controller,
    required this.focusNode,
    required this.scrollController,
    this.toolbarKey,
    this.editorKey,
    this.placeholder = 'Start writing…',
    super.key,
  });

  final QuillController controller;
  final FocusNode focusNode;
  final ScrollController scrollController;
  final Key? toolbarKey;
  final Key? editorKey;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.subtle,
        border: Border.all(color: colors.border),     
      ),
      child: Column(
        children: [
          QuillSimpleToolbar(
            key: toolbarKey,
            controller: controller,
            config: const QuillSimpleToolbarConfig(
              sectionDividerSpace: 0,
              multiRowsDisplay: false,
              showFontFamily: false,
              showFontSize: false,
              showStrikeThrough: false,
              showInlineCode: false,
              showColorButton: false,
              showBackgroundColorButton: false,
              showAlignmentButtons: false,
              showCodeBlock: false,
              showIndent: false,
              showSearchButton: false,
              showSubscript: false,
              showSuperscript: false,
            ),
          ),

          Expanded(
            child: QuillEditor(
              key: editorKey,
              controller: controller,
              focusNode: focusNode,
              scrollController: scrollController,
              config: QuillEditorConfig(
                expands: true,
                showCursor: true,
                padding: const EdgeInsets.fromLTRB(16, 36, 16, 16),
                placeholder: placeholder,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
