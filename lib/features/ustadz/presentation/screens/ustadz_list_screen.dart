import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/core/utils/extension/string_ext.dart';
import 'package:quranku/generated/locale_keys.g.dart';
import '../../../../core/components/error_screen.dart';
import '../../../../core/components/search_box.dart';
import '../../../../core/route/root_router.dart';
import '../blocs/ustadz_list/ustadz_list_bloc.dart';
import '../components/ustadz_tile.dart';

class UstadzListScreen extends StatefulWidget {
  const UstadzListScreen({super.key});

  @override
  State<UstadzListScreen> createState() => _UstadzListScreenState();
}

class _UstadzListScreenState extends State<UstadzListScreen> {
  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      context.read<UstadzListBloc>().add(
            LoadUstadzList(
              locale: Localizations.localeOf(context),
            ),
          );
      _hasLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const _UstadzListScaffold();
  }
}

class _UstadzListScaffold extends StatefulWidget {
  const _UstadzListScaffold();

  @override
  State<_UstadzListScaffold> createState() => _UstadzListScaffoldState();
}

class _UstadzListScaffoldState extends State<_UstadzListScaffold> {
  final ScrollController _scrollController = ScrollController();
  late bool isShowFloatingButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels > 0) {
      if (!isShowFloatingButton) {
        setState(() {
          isShowFloatingButton = true;
        });
      }
    } else {
      if (isShowFloatingButton) {
        setState(() {
          isShowFloatingButton = false;
        });
      }
    }
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        mounted) {
      final bloc = context.read<UstadzListBloc>();
      final currentState = bloc.state;
      if (currentState.ustadzList != null &&
          !currentState.hasReachedMax &&
          !currentState.isLoadingMore) {
        bloc.add(
          LoadUstadzList(
            querySearch: currentState.querySearch,
            locale: Localizations.localeOf(context),
            page: currentState.currentPage + 1,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.ustadz.tr()),
      ),
      floatingActionButton: isShowFloatingButton
          ? FloatingActionButton(
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              child: const Icon(Icons.arrow_upward),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: BlocBuilder<UstadzListBloc, UstadzListState>(
              buildWhen: (state, previous) =>
                  state.querySearch != previous.querySearch,
              builder: (context, state) {
                return SearchBox(
                  initialValue: state.querySearch ?? emptyString,
                  hintText:
                      '${LocaleKeys.search.tr()} ${LocaleKeys.ustadz.tr()}...',
                  onChanged: (value) {
                    context.read<UstadzListBloc>().add(
                          LoadUstadzList(
                            querySearch: value,
                            locale: Localizations.localeOf(context),
                          ),
                        );
                  },
                );
              },
            ),
          ),
          Expanded(
            child: BlocConsumer<UstadzListBloc, UstadzListState>(
              listener: (context, state) {
                if (state.status.isFailure &&
                    state.ustadzList != null &&
                    state.ustadzList!.isNotEmpty) {
                  context.showErrorToast(state.errorMessage ??
                      LocaleKeys.defaultErrorMessage.tr());
                }
              },
              builder: (context, state) {
                if (state.status == FormzSubmissionStatus.inProgress) {
                  if (state.currentPage == 1) {
                    return const Center(child: CircularProgressIndicator());
                  }
                }
                if (state.status.isFailure &&
                    (state.ustadzList == null ||
                        state.ustadzList?.isEmpty == true)) {
                  return ErrorScreen(
                    message: state.errorMessage,
                    onRefresh: () {
                      context.read<UstadzListBloc>().add(
                            LoadUstadzList(
                              querySearch: state.querySearch,
                              locale: Localizations.localeOf(context),
                            ),
                          );
                    },
                  );
                }
                if (state.ustadzList == null || state.ustadzList!.isEmpty) {
                  return ErrorScreen(
                    message: LocaleKeys.noData.tr(),
                    iconType: IconType.info,
                  );
                }
                final ustadzList = state.ustadzList ?? [];
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<UstadzListBloc>().add(
                          LoadUstadzList(
                            querySearch: state.querySearch,
                            locale: Localizations.localeOf(context),
                          ),
                        );
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: state.isLoadingMore
                        ? ustadzList.length + 1
                        : ustadzList.length,
                    itemBuilder: (context, index) {
                      if (state.isLoadingMore && index == ustadzList.length) {
                        return const Center(
                          child: LinearProgressIndicator(),
                        );
                      }
                      final ustadz = ustadzList[index];
                      return UstadzTile(
                        ustadz: ustadz,
                        onTap: (ustadz) {
                          context.pushNamed(
                            RootRouter.ustadzDetailRoute.name,
                            pathParameters: {'id': ustadz.id.toString()},
                            extra: ustadz,
                          );
                        },
                      );
                    },
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
