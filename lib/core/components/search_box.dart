import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';

import '../utils/debouncer.dart';

class SearchBox extends StatefulWidget {
  const SearchBox({
    super.key,
    required this.initialValue,
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.isDense = false,
    this.padding,
    this.onClear,
    this.backgroundColor,
    this.border,
    this.borderRadius,
  });

  final String initialValue;
  final String hintText;
  final void Function(String)? onChanged;
  final void Function(String?)? onSubmitted;
  final Color? backgroundColor;
  final BoxBorder? border;
  final BorderRadius? borderRadius;

  /// Callback when clear button is pressed
  /// If null, clear button will not be shown
  /// should be null when initialValue is empty
  final void Function()? onClear;
  final bool isDense;
  final EdgeInsetsGeometry? padding;

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  late TextEditingController textController;
  final debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(
      text: widget.initialValue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: widget.backgroundColor ??
            context.theme.colorScheme.surfaceContainer,
        border: widget.border,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Symbols.search,
            color: context.theme.colorScheme.onSurface,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: textController,
              onTapOutside: (_) => context.dismissKeyboard(),
              onFieldSubmitted: widget.onSubmitted,
              textInputAction: TextInputAction.search,
              onChanged: widget.onChanged != null
                  ? (val) {
                      debouncer.run(() {
                        widget.onChanged?.call(val);
                      });
                    }
                  : null,
              decoration: InputDecoration(
                isDense: widget.isDense,
                contentPadding: const EdgeInsets.all(0),
                hintText: widget.hintText,
                hintStyle: context.theme.textTheme.titleSmall?.copyWith(
                  color: context.theme.colorScheme.onSurface
                      .withValues(alpha: 0.5),
                ),
                labelStyle: context.theme.textTheme.titleSmall,
                focusedBorder: InputBorder.none,
                border: InputBorder.none,
              ),
            ),
          ),
          widget.onClear != null && textController.text.isNotEmpty
              ? InkWell(
                  onTap: () {
                    textController.clear();
                    widget.onClear?.call();
                  },
                  child: Icon(
                    Icons.close,
                    color: context.theme.colorScheme.onSurface,
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
