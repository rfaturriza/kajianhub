import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/features/kajian/domain/usecases/get_kajian_list_usecase.dart';
import 'package:quranku/generated/locale_keys.g.dart';

import '../../../../kajian/data/models/kajian_schedule_request_model.codegen.dart';
import '../../../../kajian/domain/entities/kajian_schedule.codegen.dart';

part 'study_location_detail_state.dart';
part 'study_location_detail_event.dart';
part 'study_location_detail_bloc.freezed.dart';

@injectable
class StudyLocationDetailBloc
    extends Bloc<StudyLocationDetailEvent, StudyLocationDetailState> {
  final GetKajianListUseCase _getKajianListUseCase;
  StudyLocationDetailBloc(
    this._getKajianListUseCase,
  ) : super(const StudyLocationDetailState()) {
    on<_LoadStudies>(_onLoadStudies);
  }

  Future<void> _onLoadStudies(
    _LoadStudies event,
    Emitter<StudyLocationDetailState> emit,
  ) async {
    if (state.hasReachedMax) return;
    emit(state.copyWith(
      statusKajian: FormzSubmissionStatus.inProgress,
    ));
    final kajianRequest = KajianScheduleRequestModel(
      page: event.page,
      options: [
        'filter,location_id,equal,${event.studyLocationId}',
      ],
    );
    final result = await _getKajianListUseCase(
      kajianRequest,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          statusKajian: FormzSubmissionStatus.failure,
          errorMessage: failure.errorMessage,
        ),
      ),
      (kajianList) {
        if (kajianList.meta.total == state.totalData &&
            kajianList.meta.currentPage == state.currentPage) {
          emit(state.copyWith(
            hasReachedMax: true,
            statusKajian: FormzSubmissionStatus.failure,
            errorMessage: LocaleKeys.searchKajianEmpty.tr(),
          ));
          return;
        }
        emit(state.copyWith(
          currentPage: kajianList.meta.currentPage ?? 1,
          totalData: kajianList.meta.total,
          lastPage: kajianList.meta.lastPage,
          hasReachedMax: state.currentPage >= (kajianList.meta.lastPage ?? 1),
          kajianResult: [
            ...state.kajianResult,
            ...kajianList.data,
          ],
          statusKajian: FormzSubmissionStatus.success,
        ));
      },
    );
  }
}
