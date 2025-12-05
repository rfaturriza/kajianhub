import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/generated/locale_keys.g.dart';
import '../../../../core/components/spacer.dart';
import '../blocs/tasbih_bloc.dart';

class TasbihMainCounter extends StatelessWidget {
  const TasbihMainCounter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasbihBloc, TasbihState>(
      builder: (context, state) {
        final selectedCounter = state.selectedCounter;

        if (selectedCounter == null) {
          return Center(
            child: Text(
              LocaleKeys.selectTasbihToStart.tr(),
              style: context.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Arabic Text
              Text(
                selectedCounter.arabicText,
                style: context.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                ),
                // textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
              ),
              const VSpacer(height: 16),

              // Transliteration
              Text(
                selectedCounter.transliteration,
                style: context.textTheme.titleLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const VSpacer(height: 8),

              // Translation
              Text(
                selectedCounter.translation,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const VSpacer(height: 32),

              // Progress Indicator
              SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background Circle
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 12,
                        backgroundColor:
                            context.theme.colorScheme.surfaceContainer,
                        valueColor: AlwaysStoppedAnimation(
                          context.theme.colorScheme.surfaceContainer,
                        ),
                      ),
                    ),
                    // Progress Circle
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: selectedCounter.progress,
                        strokeWidth: 12,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation(
                          selectedCounter.isTargetReached
                              ? context.theme.colorScheme.primary
                              : context.theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                    // Counter Display
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selectedCounter.count.toString(),
                          style: context.textTheme.headlineLarge?.copyWith(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: selectedCounter.isTargetReached
                                ? context.theme.colorScheme.primary
                                : context.theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '/ ${selectedCounter.target}',
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: context.theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const VSpacer(height: 24),

              // Target Reached Indicator
              if (selectedCounter.isTargetReached)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Symbols.check_circle,
                        color: context.theme.colorScheme.primary,
                        size: 20,
                      ),
                      const HSpacer(width: 8),
                      Text(
                        LocaleKeys.targetReached.tr(),
                        style: context.textTheme.labelLarge?.copyWith(
                          color: context.theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              const VSpacer(height: 32),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Reset Button
                  IconButton.outlined(
                    onPressed: () => context.read<TasbihBloc>().add(
                          TasbihEvent.resetCounter(selectedCounter.id),
                        ),
                    icon: const Icon(Symbols.refresh),
                    iconSize: 32,
                    style: IconButton.styleFrom(
                      minimumSize: const Size(64, 64),
                    ),
                  ),

                  // Main Counter Button
                  GestureDetector(
                    onTap: () => context.read<TasbihBloc>().add(
                          TasbihEvent.incrementCounter(selectedCounter.id),
                        ),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: context.theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                context.theme.colorScheme.primary.withAlpha(50),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        Symbols.touch_app,
                        color: context.theme.colorScheme.onPrimary,
                        size: 48,
                      ),
                    ),
                  ),

                  // Settings Button
                  IconButton.outlined(
                    onPressed: () {}, // Settings handled by parent screen
                    icon: const Icon(Symbols.settings),
                    iconSize: 32,
                    style: IconButton.styleFrom(
                      minimumSize: const Size(64, 64),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
