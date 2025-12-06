import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:formz/formz.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/features/tasbih/domain/entities/tasbih_counter.codegen.dart';
import 'package:quranku/generated/locale_keys.g.dart';
import 'package:quranku/injection.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/components/spacer.dart';
import '../../../../core/components/error_screen.dart';
import '../../../setting/presentation/bloc/styling_setting/styling_setting_bloc.dart';
import '../blocs/tasbih_bloc.dart';
import '../components/tasbih_settings_bottom_sheet.dart';
import 'dart:ui' as ui;

class TasbihScreen extends StatelessWidget {
  const TasbihScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TasbihBloc>(),
      child: const _TasbihView(),
    );
  }
}

class _TasbihView extends StatelessWidget {
  const _TasbihView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(
          context.isDarkMode
              ? AssetConst.kajianHubTextLogoLight
              : AssetConst.kajianHubTextLogoDark,
          width: 100,
          errorBuilder: (context, error, stackTrace) =>
              Text(LocaleKeys.tasbih.tr()),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              final tasbihBloc = context.read<TasbihBloc>();
              switch (value) {
                case 'reset_all':
                  _showResetAllDialog(context, tasbihBloc);
                  break;
                case 'add_custom':
                  _showAddCustomDialog(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'reset_all',
                child: Row(
                  children: [
                    const Icon(Symbols.refresh),
                    const HSpacer(width: 8),
                    Text(
                      LocaleKeys.resetAll.tr(),
                      style: context.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'add_custom',
                child: Row(
                  children: [
                    const Icon(Symbols.add),
                    const HSpacer(width: 8),
                    Text(
                      LocaleKeys.addCustom.tr(),
                      style: context.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocConsumer<TasbihBloc, TasbihState>(
        listener: (context, state) {
          if (state.isFailure && state.errorMessage != null) {
            context.showErrorToast(state.errorMessage!);
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.counters.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.counters.isEmpty) {
            return ErrorScreen(
              message: LocaleKeys.noTasbihCounters.tr(),
              onRefresh: () => context.read<TasbihBloc>().add(
                    const TasbihEvent.loadCounters(),
                  ),
            );
          }

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: _MainCounterSection(
                    selectedCounter: state.selectedCounter,
                    onSettings: () => _showSettingsBottomSheet(context),
                  ),
                ),
              ];
            },
            body: _CounterSelectionSection(
              counters: state.counters,
              selectedCounterId: state.selectedCounterId,
              onCounterSelected: (counterId) => context.read<TasbihBloc>().add(
                    TasbihEvent.selectCounter(counterId),
                  ),
              onCounterLongPress: (counter) => _showCounterOptionsDialog(
                context,
                counter,
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<TasbihBloc>(),
        child: const TasbihSettingsBottomSheet(),
      ),
    );
  }

  void _showResetAllDialog(BuildContext context, TasbihBloc tasbihBloc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocaleKeys.resetAllCounters.tr()),
        content: Text(LocaleKeys.resetAllCountersConfirmation.tr()),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(LocaleKeys.cancel.tr()),
          ),
          TextButton(
            onPressed: () {
              tasbihBloc.add(const TasbihEvent.resetAllCounters());
              context.pop();
            },
            child: Text(LocaleKeys.reset.tr()),
          ),
        ],
      ),
    );
  }

  void _showAddCustomDialog(BuildContext context) {
    final nameController = TextEditingController();
    final arabicController = TextEditingController();
    final transliterationController = TextEditingController();
    final translationController = TextEditingController();
    final targetController = TextEditingController(text: '33');

    // Get the BLoC reference before showing the dialog
    final tasbihBloc = context.read<TasbihBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: tasbihBloc,
        child: AlertDialog(
          title: Text(LocaleKeys.addCustomTasbih.tr()),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: LocaleKeys.name.tr(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const VSpacer(height: 12),
                  BlocBuilder<StylingSettingBloc, StylingSettingState>(
                    buildWhen: (p, c) =>
                        p.fontFamilyArabic != c.fontFamilyArabic,
                    builder: (context, stylingState) {
                      return TextField(
                        controller: arabicController,
                        style: context.textTheme.bodyMedium?.copyWith(
                          height: 2.0,
                          fontFamily: stylingState.fontFamilyArabic,
                          color: context.theme.colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          labelText: LocaleKeys.arabicText.tr(),
                          border: const OutlineInputBorder(),
                        ),
                        textDirection: ui.TextDirection.rtl,
                      );
                    },
                  ),
                  const VSpacer(height: 12),
                  TextField(
                    controller: transliterationController,
                    decoration: InputDecoration(
                      labelText: LocaleKeys.transliteration.tr(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const VSpacer(height: 12),
                  TextField(
                    controller: translationController,
                    decoration: InputDecoration(
                      labelText: LocaleKeys.translation.tr(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const VSpacer(height: 12),
                  TextField(
                    controller: targetController,
                    decoration: InputDecoration(
                      labelText: LocaleKeys.target.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(LocaleKeys.cancel.tr()),
            ),
            BlocConsumer<TasbihBloc, TasbihState>(
              listener: (context, state) {
                if (state.status == FormzSubmissionStatus.success) {
                  Navigator.of(dialogContext).pop();
                }
                if (state.status == FormzSubmissionStatus.failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          state.errorMessage ?? 'Error creating custom tasbih'),
                    ),
                  );
                }
              },
              builder: (context, state) {
                return TextButton(
                  onPressed: state.status == FormzSubmissionStatus.inProgress
                      ? null
                      : () {
                          if (nameController.text.isNotEmpty &&
                              arabicController.text.isNotEmpty &&
                              targetController.text.isNotEmpty) {
                            context.read<TasbihBloc>().add(
                                  TasbihEvent.createCustomCounter(
                                    name: nameController.text,
                                    arabicText: arabicController.text,
                                    transliteration:
                                        transliterationController.text,
                                    translation: translationController.text,
                                    target:
                                        int.tryParse(targetController.text) ??
                                            33,
                                  ),
                                );
                          }
                        },
                  child: state.status == FormzSubmissionStatus.inProgress
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(LocaleKeys.add.tr()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCounterOptionsDialog(BuildContext context, TasbihCounter counter) {
    final tasbihBloc = context.read<TasbihBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: tasbihBloc,
        child: AlertDialog(
          title: Text(counter.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Symbols.refresh),
                title: Text(LocaleKeys.resetCounter.tr()),
                onTap: () {
                  context.read<TasbihBloc>().add(
                        TasbihEvent.resetCounter(counter.id),
                      );
                  Navigator.of(dialogContext).pop();
                },
              ),
              ListTile(
                leading: const Icon(Symbols.edit),
                title: Text(LocaleKeys.editTarget.tr()),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _showEditTargetDialog(context, counter);
                },
              ),
              // Only show delete for custom counters (not default ones)
              if (![
                'subhanallah',
                'alhamdulillah',
                'allahu_akbar',
                'la_ilaha_illallah',
                'astaghfirullah',
                'la_hawla_wala_quwwata'
              ].contains(counter.id))
                ListTile(
                  leading: Icon(Symbols.delete,
                      color: context.theme.colorScheme.error),
                  title: Text(LocaleKeys.delete.tr(),
                      style: TextStyle(color: context.theme.colorScheme.error)),
                  onTap: () {
                    context.read<TasbihBloc>().add(
                          TasbihEvent.deleteCustomCounter(counter.id),
                        );
                    Navigator.of(dialogContext).pop();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditTargetDialog(BuildContext context, TasbihCounter counter) {
    final targetController =
        TextEditingController(text: counter.target.toString());
    final tasbihBloc = context.read<TasbihBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: tasbihBloc,
        child: AlertDialog(
          title: Text(LocaleKeys.editTarget.tr()),
          content: TextField(
            controller: targetController,
            decoration: InputDecoration(
              labelText: LocaleKeys.target.tr(),
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(LocaleKeys.cancel.tr()),
            ),
            TextButton(
              onPressed: () {
                final newTarget = int.tryParse(targetController.text);
                if (newTarget != null && newTarget > 0) {
                  context.read<TasbihBloc>().add(
                        TasbihEvent.updateTarget(counter.id, newTarget),
                      );
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(LocaleKeys.save.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainCounterSection extends StatelessWidget {
  final TasbihCounter? selectedCounter;
  final VoidCallback onSettings;

  const _MainCounterSection({
    required this.selectedCounter,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedCounter == null) {
      return Container(
        height: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.counter_1,
              size: 80,
              color: context.theme.colorScheme.primary.withAlpha(150),
            ),
            const VSpacer(height: 16),
            Text(
              LocaleKeys.selectTasbihToStart.tr(),
              style: context.textTheme.titleLarge?.copyWith(
                color: context.theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Arabic Text
          BlocBuilder<StylingSettingBloc, StylingSettingState>(
            buildWhen: (p, c) =>
                p.fontFamilyArabic != c.fontFamilyArabic ||
                p.arabicFontSize != c.arabicFontSize,
            builder: (context, stylingState) {
              return Text(
                selectedCounter?.arabicText ?? '',
                style: context.textTheme.headlineLarge?.copyWith(
                  fontFamily: stylingState.fontFamilyArabic,
                  fontSize: stylingState.arabicFontSize,
                ),
                textAlign: TextAlign.center,
              );
            },
          ),
          const VSpacer(height: 12),

          // Transliteration
          if (selectedCounter?.transliteration.isNotEmpty ?? false)
            Text(
              selectedCounter?.transliteration ?? '',
              style: context.textTheme.titleMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: context.theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          const VSpacer(height: 8),

          // Translation
          if (selectedCounter?.translation.isNotEmpty ?? false)
            Text(
              selectedCounter?.translation ?? '',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          const VSpacer(height: 24),

          // Progress and Counter
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Progress Circle
                Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            value: selectedCounter?.progress ?? 0.0,
                            strokeWidth: 8,
                            strokeCap: StrokeCap.round,
                            backgroundColor:
                                context.theme.colorScheme.surfaceContainer,
                            valueColor: AlwaysStoppedAnimation(
                              (selectedCounter?.isTargetReached ?? false)
                                  ? context.theme.colorScheme.primary
                                  : context.theme.colorScheme.secondary,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              selectedCounter?.count.toString() ?? '0',
                              style: context.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color:
                                    (selectedCounter?.isTargetReached ?? false)
                                        ? context.theme.colorScheme.primary
                                        : context.theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '/ ${selectedCounter?.target ?? 0}',
                              style: context.textTheme.bodySmall?.copyWith(
                                color:
                                    context.theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    VSpacer(height: 16),
                    // Action buttons row
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Reset Button
                        IconButton.outlined(
                          onPressed: () => context.read<TasbihBloc>().add(
                                TasbihEvent.resetCounter(selectedCounter!.id),
                              ),
                          icon: const Icon(Symbols.refresh),
                          iconSize: 20,
                          style: IconButton.styleFrom(
                            minimumSize: const Size(40, 40),
                          ),
                        ),
                        const HSpacer(width: 8),
                        // Settings Button
                        IconButton.outlined(
                          onPressed: onSettings,
                          icon: const Icon(Symbols.settings),
                          iconSize: 20,
                          style: IconButton.styleFrom(
                            minimumSize: const Size(40, 40),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Action Buttons
                GestureDetector(
                  onTap: () => context.read<TasbihBloc>().add(
                        TasbihEvent.incrementCounter(selectedCounter!.id),
                      ),
                  child: Container(
                    padding: const EdgeInsets.all(48),
                    decoration: BoxDecoration(
                      color: context.theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              context.theme.colorScheme.primary.withAlpha(50),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Symbols.touch_app,
                      color: context.theme.colorScheme.onPrimary,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Target Reached Indicator
          if (selectedCounter?.isTargetReached ?? false) ...[
            const VSpacer(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Symbols.check_circle,
                        color: context.theme.colorScheme.onSecondaryContainer,
                        size: 20,
                      ),
                      const HSpacer(width: 8),
                      Text(
                        LocaleKeys.targetReached.tr(),
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.theme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                HSpacer(width: 16),
                // Next Button
                Expanded(
                  child: FilledButton.icon(
                    iconAlignment: IconAlignment.end,
                    onPressed: () {
                      final list = TasbihCounter.defaultTasbihList;
                      final currentIndex = list.indexWhere(
                        (c) => c.id == selectedCounter?.id,
                      );
                      final nextIndex = (currentIndex + 1) % list.length;
                      final nextCounter = list[nextIndex];
                      context.read<TasbihBloc>().add(
                            TasbihEvent.selectCounter(nextCounter.id),
                          );
                    },
                    icon: const Icon(
                      Symbols.navigate_next,
                      size: 20,
                    ),
                    label: Text(
                      LocaleKeys.next.tr(),
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.theme.colorScheme.onSecondary,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: context.theme.colorScheme.secondary,
                      foregroundColor: context.theme.colorScheme.onSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CounterSelectionSection extends StatelessWidget {
  final List<TasbihCounter> counters;
  final String? selectedCounterId;
  final Function(String) onCounterSelected;
  final Function(TasbihCounter) onCounterLongPress;

  const _CounterSelectionSection({
    required this.counters,
    required this.selectedCounterId,
    required this.onCounterSelected,
    required this.onCounterLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: context.theme.colorScheme.surfaceContainer,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.selectTasbih.tr(),
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const VSpacer(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: counters.length,
              itemBuilder: (context, index) {
                final counter = counters[index];
                final isSelected = selectedCounterId == counter.id;

                return GestureDetector(
                  onTap: () => onCounterSelected(counter.id),
                  onLongPress: () => onCounterLongPress(counter),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.theme.colorScheme.primary.withAlpha(30)
                          : context.theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? context.theme.colorScheme.primary.withAlpha(100)
                            : context.theme.colorScheme.outline.withAlpha(100),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Counter Name
                        Text(
                          counter.name,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? context.theme.colorScheme.onPrimaryContainer
                                : context.theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const VSpacer(height: 6),

                        // Arabic Text
                        Expanded(
                          child: BlocBuilder<StylingSettingBloc,
                              StylingSettingState>(
                            buildWhen: (p, c) =>
                                p.fontFamilyArabic != c.fontFamilyArabic,
                            builder: (context, stylingState) {
                              return Text(
                                counter.arabicText,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  fontFamily: stylingState.fontFamilyArabic,
                                  color: isSelected
                                      ? context
                                          .theme.colorScheme.onPrimaryContainer
                                      : context.theme.colorScheme.onSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        ),
                        const VSpacer(height: 8),

                        // Progress and Count
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(
                              value: counter.progress,
                              borderRadius: BorderRadius.circular(1000),
                              backgroundColor:
                                  context.theme.colorScheme.surfaceContainer,
                              valueColor: AlwaysStoppedAnimation(
                                counter.isTargetReached
                                    ? context.theme.colorScheme.primary
                                    : context.theme.colorScheme.secondary,
                              ),
                            ),
                            const VSpacer(height: 4),
                            Text(
                              '${counter.count}/${counter.target}',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: isSelected
                                    ? context
                                        .theme.colorScheme.onPrimaryContainer
                                    : context
                                        .theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
