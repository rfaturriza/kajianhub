import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/features/buletin/domain/entities/buletin.codegen.dart';
import 'package:quranku/features/buletin/domain/usecases/get_buletins_usecase.dart';

part 'buletin_event.dart';
part 'buletin_state.dart';
part 'buletin_bloc.freezed.dart';

@injectable
class BuletinBloc extends Bloc<BuletinEvent, BuletinState> {
  final GetBuletinsUsecase _getBuletinsUsecase;

  BuletinBloc(
    this._getBuletinsUsecase,
  ) : super(const BuletinState()) {
    on<_LoadBuletins>(_onLoadBuletins);
    on<_LoadMoreBuletins>(_onLoadMoreBuletins);
    on<_SearchBuletins>(_onSearchBuletins);
    on<_ClearSearch>(_onClearSearch);
  }

  Future<void> _onLoadBuletins(
    _LoadBuletins event,
    Emitter<BuletinState> emit,
  ) async {
    if (event.isRefresh) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.inProgress,
        currentPage: 1,
        hasReachedMax: false,
        buletins: [],
      ));
    } else if (state.status == FormzSubmissionStatus.inProgress) {
      return;
    } else {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    }

    final result = await _getBuletinsUsecase(
      query: event.query,
      page: event.isRefresh ? 1 : state.currentPage,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: failure.message,
      )),
      (buletins) => emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        buletins: event.isRefresh ? buletins : state.buletins + buletins,
        searchQuery: event.query ?? '',
        currentPage: event.isRefresh ? 2 : state.currentPage + 1,
        hasReachedMax: buletins.length < 12,
      )),
    );
  }

  Future<void> _onLoadMoreBuletins(
    _LoadMoreBuletins event,
    Emitter<BuletinState> emit,
  ) async {
    if (state.hasReachedMax ||
        state.status == FormzSubmissionStatus.inProgress) {
      return;
    }

    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    final result = await _getBuletinsUsecase(
      query: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      page: state.currentPage,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: failure.message,
      )),
      (buletins) => emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        buletins: state.buletins + buletins,
        currentPage: state.currentPage + 1,
        hasReachedMax: buletins.length < 12,
      )),
    );
  }

  Future<void> _onSearchBuletins(
    _SearchBuletins event,
    Emitter<BuletinState> emit,
  ) async {
    emit(state.copyWith(
      status: FormzSubmissionStatus.inProgress,
      currentPage: 1,
      hasReachedMax: false,
      buletins: [],
      searchQuery: event.query,
    ));

    final result = await _getBuletinsUsecase(
      query: event.query,
      page: 1,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: failure.message,
      )),
      (buletins) => emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        buletins: buletins,
        currentPage: 2,
        hasReachedMax: buletins.length < 12,
      )),
    );
  }

  Future<void> _onClearSearch(
    _ClearSearch event,
    Emitter<BuletinState> emit,
  ) async {
    emit(state.copyWith(
      searchQuery: '',
      currentPage: 1,
      hasReachedMax: false,
      buletins: [],
      status: FormzSubmissionStatus.inProgress,
    ));

    final result = await _getBuletinsUsecase(page: 1);

    result.fold(
      (failure) => emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: failure.message,
      )),
      (buletins) => emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        buletins: buletins,
        currentPage: 2,
        hasReachedMax: buletins.length < 12,
      )),
    );
  }
}
