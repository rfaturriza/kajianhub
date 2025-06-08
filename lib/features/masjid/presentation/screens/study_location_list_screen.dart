import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/generated/locale_keys.g.dart';
import '../../../../core/components/search_box.dart';
import '../../../../core/route/root_router.dart';
import '../blocs/study_location_list/study_location_list_bloc.dart';
import '../components/mosque_tile.dart';

class StudyLocationListScreen extends StatefulWidget {
  const StudyLocationListScreen({super.key});

  @override
  State<StudyLocationListScreen> createState() =>
      _StudyLocationListScreenState();
}

class _StudyLocationListScreenState extends State<StudyLocationListScreen> {
  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      context.read<StudyLocationListBloc>().add(
            LoadMasjidList(
              locale: Localizations.localeOf(context),
            ),
          );
      _hasLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const _StudyLocationListScaffold();
  }
}

class _StudyLocationListScaffold extends StatefulWidget {
  const _StudyLocationListScaffold();

  @override
  State<_StudyLocationListScaffold> createState() =>
      _StudyLocationListScaffoldState();
}

class _StudyLocationListScaffoldState
    extends State<_StudyLocationListScaffold> {
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
      final bloc = context.read<StudyLocationListBloc>();
      final currentState = bloc.state;
      if (currentState.studyLocations != null &&
          !currentState.hasReachedMax &&
          !currentState.isLoadingMore) {
        bloc.add(
          LoadMasjidList(
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
        title: const Text(LocaleKeys.mosque).tr(),
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
            child: SearchBox(
              initialValue: '',
              hintText: LocaleKeys.search.tr(),
              onChanged: (value) {
                context.read<StudyLocationListBloc>().add(
                      LoadMasjidList(
                        querySearch: value,
                        locale: Localizations.localeOf(context),
                      ),
                    );
              },
            ),
          ),
          Expanded(
            child: BlocConsumer<StudyLocationListBloc, StudyLocationListState>(
              listener: (context, state) {
                if (state.status.isFailure &&
                    state.studyLocations != null &&
                    state.studyLocations!.isNotEmpty) {
                  context.showErrorToast(state.errorMessage);
                }
              },
              builder: (context, state) {
                if (state.status == FormzSubmissionStatus.inProgress) {
                  if (state.currentPage == 1) {
                    return const Center(child: CircularProgressIndicator());
                  }
                }
                if (state.status.isFailure &&
                    (state.studyLocations == null ||
                        state.studyLocations?.isEmpty == true)) {
                  return ListTile(
                    title: Text(
                      state.errorMessage.isNotEmpty
                          ? state.errorMessage
                          : LocaleKeys.defaultErrorMessage.tr(),
                    ),
                    leading: const Icon(Symbols.warning_amber_rounded),
                  );
                }
                final studyLocations = state.studyLocations ?? [];
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: state.isLoadingMore
                      ? studyLocations.length + 1
                      : studyLocations.length,
                  itemBuilder: (context, index) {
                    if (state.isLoadingMore && index == studyLocations.length) {
                      return const Center(
                        child: LinearProgressIndicator(),
                      );
                    }
                    final mosque = studyLocations[index];
                    return MosqueTile(
                      location: mosque,
                      onTap: (mosque) {
                        context.pushNamed(
                          RootRouter.studyLocationDetailRoute.name,
                          pathParameters: {'id': mosque.id.toString()},
                          extra: mosque,
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
