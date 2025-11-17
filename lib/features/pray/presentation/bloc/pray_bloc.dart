import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/features/pray/domain/entities/prayer.codegen.dart';
import 'package:quranku/features/pray/domain/usecases/get_prayers_usecase.dart';

part 'pray_bloc.freezed.dart';
part 'pray_event.dart';
part 'pray_state.dart';

@injectable
class PrayBloc extends Bloc<PrayEvent, PrayState> {
  final GetPrayersUsecase _getPrayersUsecase;

  PrayBloc(this._getPrayersUsecase) : super(const PrayState()) {
    on<_FetchPrayers>(_onFetchPrayers);
    on<_LoadMorePrayers>(_onLoadMorePrayers);
    on<_SearchPrayers>(_onSearchPrayers);
    on<_ClearSearch>(_onClearSearch);
  }

  Future<void> _onFetchPrayers(
    _FetchPrayers event,
    Emitter<PrayState> emit,
  ) async {
    emit(state.copyWith(
      status: FormzSubmissionStatus.inProgress,
      prayers: event.page == 1 ? [] : state.prayers,
      hasReachedMax: event.page == 1 ? false : state.hasReachedMax,
      isLoadingMore: false,
    ));

    final result = await _getPrayersUsecase(GetPrayersParams(
      query: event.query,
      page: event.page,
      limit: event.limit,
      orderBy: event.orderBy,
      sortBy: event.sortBy,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to load prayers',
        isLoadingMore: false,
      )),
      (prayers) => emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        prayers: event.page == 1 ? prayers : [...state.prayers, ...prayers],
        currentPage: event.page,
        hasReachedMax: prayers.length < event.limit,
        isLoadingMore: false,
      )),
    );
  }

  Future<void> _onLoadMorePrayers(
    _LoadMorePrayers event,
    Emitter<PrayState> emit,
  ) async {
    if (state.hasReachedMax || state.isLoadingMore) return;

    emit(state.copyWith(isLoadingMore: true));

    final result = await _getPrayersUsecase(GetPrayersParams(
      query: state.searchQuery,
      page: state.currentPage + 1,
    ));

    result.fold(
      (failure) => emit(state.copyWith(isLoadingMore: false)),
      (prayers) => emit(state.copyWith(
        prayers: [...state.prayers, ...prayers],
        currentPage: state.currentPage + 1,
        hasReachedMax: prayers.length < 12,
        isLoadingMore: false,
      )),
    );
  }

  Future<void> _onSearchPrayers(
    _SearchPrayers event,
    Emitter<PrayState> emit,
  ) async {
    emit(state.copyWith(
      searchQuery: event.query,
      hasReachedMax: false,
      isLoadingMore: false,
    ));
    add(PrayEvent.fetchPrayers(query: event.query));
  }

  void _onClearSearch(
    _ClearSearch event,
    Emitter<PrayState> emit,
  ) {
    emit(state.copyWith(
      searchQuery: null,
      hasReachedMax: false,
      isLoadingMore: false,
    ));
    add(const PrayEvent.fetchPrayers());
  }
}
