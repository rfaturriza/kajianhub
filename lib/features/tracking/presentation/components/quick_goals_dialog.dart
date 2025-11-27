import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';

import '../../../../generated/locale_keys.g.dart';

class QuickGoalsDialog extends StatefulWidget {
  final int currentAyahGoal;
  final int currentMinuteGoal;
  final Function(int ayahGoal, int minuteGoal) onSave;

  const QuickGoalsDialog({
    super.key,
    required this.currentAyahGoal,
    required this.currentMinuteGoal,
    required this.onSave,
  });

  @override
  State<QuickGoalsDialog> createState() => _QuickGoalsDialogState();
}

class _QuickGoalsDialogState extends State<QuickGoalsDialog> {
  late TextEditingController ayahController;
  late TextEditingController minuteController;

  @override
  void initState() {
    super.initState();
    ayahController =
        TextEditingController(text: widget.currentAyahGoal.toString());
    minuteController =
        TextEditingController(text: widget.currentMinuteGoal.toString());
  }

  @override
  void dispose() {
    ayahController.dispose();
    minuteController.dispose();
    super.dispose();
  }

  void _saveGoals() {
    final ayahGoal = int.tryParse(ayahController.text);
    final minuteGoal = int.tryParse(minuteController.text);

    if (ayahGoal == null || ayahGoal < 1 || ayahGoal > 200) {
      context.showErrorToast('Please enter a valid ayah goal (1-200)');
      return;
    }

    if (minuteGoal == null || minuteGoal < 1 || minuteGoal > 120) {
      context.showErrorToast('Please enter a valid minute goal (1-120)');
      return;
    }

    widget.onSave(ayahGoal, minuteGoal);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Symbols.flag,
            color: context.theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          const Text(LocaleKeys.setDailyGoals).tr(),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            LocaleKeys.setDailyGoalsDescription.tr(),
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              TextField(
                controller: ayahController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: LocaleKeys.verses.tr(),
                  hintText: 'e.g., 30',
                  suffix: Text(LocaleKeys.verses.tr()),
                  prefixIcon: const Icon(Symbols.menu_book, size: 20),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: minuteController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: LocaleKeys.minutes.tr(),
                  hintText: 'e.g., 20',
                  suffix: Text(LocaleKeys.minutes.tr()),
                  prefixIcon: const Icon(Symbols.schedule, size: 20),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${LocaleKeys.quickPreset.tr()}:',
            style: context.textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildPresetChip(LocaleKeys.beginner.tr(), 15, 10),
              _buildPresetChip(LocaleKeys.moderate.tr(), 30, 20),
              _buildPresetChip(LocaleKeys.advanced.tr(), 50, 35),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(LocaleKeys.cancel.tr()),
        ),
        FilledButton.icon(
          onPressed: _saveGoals,
          icon: const Icon(Symbols.save),
          label: Text(LocaleKeys.saveButtonLabel.tr()),
        ),
      ],
    );
  }

  Widget _buildPresetChip(String label, int ayahs, int minutes) {
    return FilterChip(
      label: Text('$label ($ayahs/$minutes)'),
      selected: false,
      onSelected: (_) {
        ayahController.text = ayahs.toString();
        minuteController.text = minutes.toString();
        HapticFeedback.lightImpact();
      },
    );
  }
}
