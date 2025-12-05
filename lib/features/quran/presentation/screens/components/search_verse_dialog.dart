import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quranku/generated/locale_keys.g.dart';

class SearchVerseDialog extends StatefulWidget {
  final int maxVerses;
  final Function(int verseNumber) onVerseSelected;

  const SearchVerseDialog({
    super.key,
    required this.maxVerses,
    required this.onVerseSelected,
  });

  @override
  State<SearchVerseDialog> createState() => _SearchVerseDialogState();
}

class _SearchVerseDialogState extends State<SearchVerseDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _searchVerse() {
    if (_formKey.currentState?.validate() ?? false) {
      final verseNumber = int.tryParse(_controller.text.trim());
      if (verseNumber != null &&
          verseNumber >= 1 &&
          verseNumber <= widget.maxVerses) {
        Navigator.of(context).pop();
        widget.onVerseSelected(verseNumber);
      } else {
        setState(() {
          _errorText = LocaleKeys.invalidVerseNumber.tr();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(LocaleKeys.searchVerse.tr()),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: LocaleKeys.searchVerseHint.tr(),
                border: const OutlineInputBorder(),
                errorText: _errorText,
                helperText: LocaleKeys.rangeLabel.tr(namedArgs: {
                  'startRange': '1',
                  'endRange': widget.maxVerses.toString(),
                }),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return LocaleKeys.invalidVerseNumber.tr();
                }
                final number = int.tryParse(value!);
                if (number == null || number < 1 || number > widget.maxVerses) {
                  return LocaleKeys.invalidVerseNumber.tr();
                }
                return null;
              },
              onChanged: (value) {
                if (_errorText != null) {
                  setState(() {
                    _errorText = null;
                  });
                }
              },
              onFieldSubmitted: (_) => _searchVerse(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(LocaleKeys.cancel.tr()),
        ),
        FilledButton(
          onPressed: _searchVerse,
          child: Text(LocaleKeys.gotoVerse.tr()),
        ),
      ],
    );
  }
}
