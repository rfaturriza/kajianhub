import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/features/ustadz/domain/entities/ustadz_entity.codegen.dart';

import '../../../data/models/ustadz_query_model.codegen.dart';
import '../../../domain/usecases/get_ustadz_list_usecase.dart';

part 'ustadz_list_event.dart';
part 'ustadz_list_state.dart';
part 'ustadz_list_bloc.freezed.dart';

@injectable
class UstadzListBloc extends Bloc<UstadzListEvent, UstadzListState> {
  final GetUstadzListUseCase _getUstadzListUseCase;

  UstadzListBloc({
    required GetUstadzListUseCase getUstadzListUseCase,
  })  : _getUstadzListUseCase = getUstadzListUseCase,
        super(const UstadzListState()) {
    on<LoadUstadzList>(_onLoadUstadzList);
  }

  Future<void> _onLoadUstadzList(
    LoadUstadzList event,
    Emitter<UstadzListState> emit,
  ) async {
    // Only show loading indicator for first page
    if (state.hasReachedMax && event.page > 1) return;
    if (event.page == 1) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.inProgress,
          hasReachedMax: false, // Reset hasReachedMax for new searches
        ),
      );
    }

    if (event.page > 1) {
      emit(
        state.copyWith(
          isLoadingMore: true,
        ),
      );
    }
    final params = GetUstadzListParams(
      queries: UstadzQueryModel(
        page: event.page,
        q: event.querySearch,
        type: 'pagination',
        limit: 20,
        orderBy: 'id',
        sortBy: 'asc',
        relations: [
          'province',
          'city',
          'roles',
        ],
      ),
    );
    final result = await _getUstadzListUseCase(params);
    result.fold(
      (e) => emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.errorMessage,
          isLoadingMore: false,
        ),
      ),
      (ustadzResponse) => emit(
        // Merge new page results
        () {
          final List<UstadzEntity> newList;
          final dataList = ustadzResponse.data ?? [];
          if (event.page == 1) {
            newList = dataList;
          } else {
            newList = List.of(state.ustadzList ?? [])..addAll(dataList);
          }
          final currentPage = ustadzResponse.meta?.currentPage ?? event.page;
          final totalPage = ustadzResponse.meta?.lastPage;
          final hasReachedMax = totalPage != null && currentPage >= totalPage;
          return state.copyWith(
            status: FormzSubmissionStatus.success,
            ustadzList: newList,
            currentPage: currentPage,
            lastPage: totalPage,
            totalData: ustadzResponse.meta?.total ?? 0,
            hasReachedMax: hasReachedMax,
            isLoadingMore: false,
            querySearch: event.querySearch,
          );
        }(),
      ),
    );
  }
}
