import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:quranku/core/route/root_router.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/features/buletin/presentation/blocs/buletin_bloc.dart';
import 'package:quranku/features/buletin/presentation/components/buletin_tile.dart';
import 'package:quranku/generated/locale_keys.g.dart';
import 'package:quranku/injection.dart';

import '../../../../core/components/search_box.dart';

class BuletinScreen extends StatelessWidget {
  const BuletinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<BuletinBloc>()..add(const BuletinEvent.loadBuletins()),
      child: const BuletinView(),
    );
  }
}

class BuletinView extends StatefulWidget {
  const BuletinView({super.key});

  @override
  State<BuletinView> createState() => _BuletinViewState();
}

class _BuletinViewState extends State<BuletinView> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<BuletinBloc>().add(const BuletinEvent.loadMoreBuletins());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.buletin.tr()),
        backgroundColor: context.theme.colorScheme.surface,
        foregroundColor: context.theme.colorScheme.onSurface,
      ),
      backgroundColor: context.theme.colorScheme.surface,
      body: Column(
        children: [
          // Search bar
          SearchBox(
            initialValue: '',
            hintText: LocaleKeys.searchBuletinHint.tr(),
            onSubmitted: (q) {
              context.read<BuletinBloc>().add(
                    BuletinEvent.searchBuletins(q ?? ''),
                  );
            },
          ),

          // Content
          Expanded(
            child: BlocBuilder<BuletinBloc, BuletinState>(
              builder: (context, state) {
                if (state.status.isInProgress && state.buletins.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state.status.isFailure && state.buletins.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Symbols.error_outline,
                          size: 64,
                          color: context.theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          LocaleKeys.errorGetBuletin.tr(),
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: context.theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () {
                            context
                                .read<BuletinBloc>()
                                .add(const BuletinEvent.loadBuletins());
                          },
                          child: Text(LocaleKeys.tryAgain.tr()),
                        ),
                      ],
                    ),
                  );
                }

                if (state.buletins.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Symbols.article_rounded,
                          size: 64,
                          color: context.theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          LocaleKeys.searchBuletinEmpty.tr(),
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: context.theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: state.hasReachedMax
                      ? state.buletins.length
                      : state.buletins.length + 1,
                  itemBuilder: (context, index) {
                    if (index >= state.buletins.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final buletin = state.buletins[index];
                    return BuletinTile(
                      key: Key(buletin.id.toString()),
                      buletin: buletin,
                      onTap: () {
                        context.pushNamed(
                          RootRouter.buletinDetailRoute.name,
                          pathParameters: {'id': buletin.id.toString()},
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
