import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';

import '../../bloc/audioVerse/audio_verse_bloc.dart';

class BottomNavPlayer extends StatelessWidget {
  const BottomNavPlayer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final audioBloc = context.read<AudioVerseBloc>();
    final colorIcon = context.theme.colorScheme.onSecondaryContainer;
    return BlocListener<AudioVerseBloc, AudioVerseState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          context.showErrorToast(
            state.errorMessage ?? '',
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.secondaryContainer,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BlocBuilder<AudioVerseBloc, AudioVerseState>(
                buildWhen: (previous, current) {
                  return previous.position != current.position ||
                      previous.duration != current.duration ||
                      previous.isLoading != current.isLoading;
                },
                builder: (context, state) {
                  if (state.isLoading) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: LinearProgressIndicator(
                        backgroundColor: colorIcon.withAlpha(100),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorIcon,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }
                  final position = state.position;
                  final duration = state.duration;
                  double progress = 0.0;
                  if (duration.inMilliseconds > 0) {
                    progress =
                        position.inMilliseconds / duration.inMilliseconds;
                    if (progress.isNaN || progress.isInfinite) progress = 0.0;
                  }
                  return TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 50),
                      curve: Curves.easeInOut,
                      tween: Tween<double>(
                        begin: 0,
                        end: progress,
                      ),
                      builder: (context, value, _) {
                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: LinearProgressIndicator(
                            value: value,
                            backgroundColor: colorIcon.withAlpha(100),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorIcon,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      });
                },
              ),
              BlocBuilder<AudioVerseBloc, AudioVerseState>(
                buildWhen: (previous, current) {
                  return previous.isLoading != current.isLoading;
                },
                builder: (context, state) {
                  if (state.isLoading) {
                    return const SizedBox.shrink();
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {
                          audioBloc
                              .add(const AudioVerseEvent.previousAudioVerse());
                        },
                        icon: const Icon(Icons.fast_rewind_outlined),
                        color: colorIcon,
                      ),
                      IconButton(
                        onPressed: () {
                          audioBloc.add(const AudioVerseEvent.seekAudioVerse(
                            position: Duration(seconds: -10),
                          ));
                        },
                        icon: const Icon(Icons.replay_10),
                        color: colorIcon,
                      ),
                      IconButton(
                        onPressed: () {
                          audioBloc.add(const AudioVerseEvent.stopAudioVerse());
                        },
                        icon: const Icon(Icons.stop_circle_outlined),
                        color: colorIcon,
                      ),
                      IconButton(
                        onPressed: () {
                          audioBloc.add(const AudioVerseEvent.seekAudioVerse(
                            position: Duration(seconds: 10),
                          ));
                        },
                        icon: const Icon(Icons.forward_10),
                        color: colorIcon,
                      ),
                      IconButton(
                        onPressed: () {
                          audioBloc.add(const AudioVerseEvent.nextAudioVerse());
                        },
                        icon: const Icon(Icons.fast_forward_outlined),
                        color: colorIcon,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
