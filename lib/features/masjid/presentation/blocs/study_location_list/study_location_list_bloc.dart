import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/core/utils/extension/dartz_ext.dart';
import 'package:quranku/features/kajian/domain/entities/study_location_entity.dart';
import 'package:quranku/features/shalat/domain/usecase/get_current_location_usecase.dart';

import '../../../data/models/study_location_query_model.codegen.dart';
import '../../../domain/usecases/get_study_location_list_usecase.dart';

part 'study_location_list_event.dart';
part 'study_location_list_state.dart';
part 'study_location_list_bloc.freezed.dart';

@injectable
class StudyLocationListBloc
    extends Bloc<StudyLocationListEvent, StudyLocationListState> {
  final GetStudyLocationListUseCase _getMasjidListUseCase;
  final GetCurrentLocationUseCase _getCurrentLocationUseCase;

  StudyLocationListBloc({
    required GetStudyLocationListUseCase getMasjidListUseCase,
    required GetCurrentLocationUseCase getCurrentLocationUseCase,
  })  : _getMasjidListUseCase = getMasjidListUseCase,
        _getCurrentLocationUseCase = getCurrentLocationUseCase,
        super(StudyLocationListState()) {
    on<LoadMasjidList>(_onLoadMasjidList);
  }

  Future<void> _onLoadMasjidList(
    LoadMasjidList event,
    Emitter<StudyLocationListState> emit,
  ) async {
    // Only show loading indicator for first page
    if (state.hasReachedMax && event.page > 1) return;
    if (event.page == 1) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.inProgress,
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
    final currentLocation = await _getCurrentLocationUseCase(
      GetCurrentLocationParams(locale: event.locale),
    );
    if (currentLocation.isLeft()) {
      emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: currentLocation.asLeft().errorMessage,
          isLoadingMore: false,
        ),
      );
      return;
    }
    final params = GetStudyLocationListParams(
      queries: StudyLocationQueryModel().copyWith(
        page: event.page,
        q: event.querySearch,
        latitude: double.tryParse(
          currentLocation.asRight()?.coordinate?.latitude ?? '',
        ),
        longitude: double.tryParse(
          currentLocation.asRight()?.coordinate?.longitude ?? '',
        ),
      ),
    );
    final result = await _getMasjidListUseCase(params);
    result.fold(
      (e) => emit(
        state.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: e.errorMessage,
          isLoadingMore: false,
        ),
      ),
      (masjids) => emit(
        // Merge new page results
        () {
          final List<StudyLocationEntity> newList;
          final dataList = masjids.data ?? [];
          if (event.page == 1) {
            newList = dataList;
          } else {
            newList = List.of(state.studyLocations ?? [])..addAll(dataList);
          }
          final currentPage = masjids.meta?.currentPage ?? event.page;
          final totalPage = masjids.meta?.lastPage;
          final hasReachedMax = totalPage != null && currentPage >= totalPage;
          return state.copyWith(
            status: FormzSubmissionStatus.success,
            studyLocations: newList,
            currentPage: currentPage,
            lastPage: totalPage,
            totalData: masjids.meta?.total ?? 0,
            hasReachedMax: hasReachedMax,
            isLoadingMore: false,
            querySearch: event.querySearch,
          );
        }(),
      ),
    );
  }
}
