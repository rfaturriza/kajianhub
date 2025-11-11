import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/features/ustad_ai/presentation/blocs/ustad_ai/ustad_ai_bloc.dart';
import 'package:quranku/generated/locale_keys.g.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final controller = TextEditingController();

  void _showDisclaimerBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.7,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Symbols.info,
                    color: context.theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    LocaleKeys.ustadzAiScreen_disclaimerTitle.tr(),
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Text(
                    LocaleKeys.ustadzAiScreen_disclaimerMessage.tr(),
                    style: context.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    void onSubmit(String value) {
      FocusScope.of(context).unfocus();
      context.read<UstadAiBloc>().add(UstadAiEvent.sendPrompt(value));
    }

    return SafeArea(
      top: false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(
            LocaleKeys.ustadzAiScreen_title.tr(),
          ),
          actions: [
            IconButton(
              onPressed: _showDisclaimerBottomSheet,
              icon: const Icon(Symbols.info),
              tooltip: LocaleKeys.ustadzAiScreen_disclaimerTitle.tr(),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: BlocBuilder<UstadAiBloc, UstadAiState>(
                  builder: (context, state) {
                    if (state is UstadAiStreamingState) {
                      if (state.text.isEmpty) {
                        return Text(
                          LocaleKeys.ustadzAiScreen_generating.tr(),
                        );
                      }
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        child: MarkdownBody(
                          data: state.text,
                          selectable: true,
                        ),
                      );
                    } else if (state is UstadAiErrorState) {
                      return SingleChildScrollView(
                        child: Text(
                          state.message,
                          style: context.textTheme.labelMedium,
                        ),
                      );
                    } else {
                      return Text(
                        LocaleKeys.ustadzAiScreen_description.tr(),
                      );
                    }
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    autofocus: true,
                    onTapOutside: (_) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: LocaleKeys.ustadzAiScreen_labelTextField.tr(),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    onSubmitted: onSubmit,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: context.theme.colorScheme.primary,
                        ),
                        color: context.theme.colorScheme.onPrimary,
                        onPressed: () {
                          final value = controller.text;
                          if (value.isNotEmpty) {
                            onSubmit(value);
                          }
                        },
                        icon: BlocBuilder<UstadAiBloc, UstadAiState>(
                          builder: (context, state) {
                            if (state is UstadAiStreamingState) {
                              if (state.isGenerating) {
                                return SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: context.theme.colorScheme.onPrimary,
                                  ),
                                );
                              }
                            }
                            return const Icon(
                              Symbols.arrow_upward_alt_rounded,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
