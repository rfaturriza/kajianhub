import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/features/kajian/domain/usecases/get_kajian_list_usecase.dart';

import '../../../../kajian/data/models/kajian_schedule_request_model.codegen.dart';
import '../../../../kajian/domain/entities/kajian_schedule.codegen.dart';

part 'ustadz_detail_state.dart';
part 'ustadz_detail_event.dart';
part 'ustadz_detail_bloc.freezed.dart';

@injectable
class UstadzDetailBloc extends Bloc<UstadzDetailEvent, UstadzDetailState> {
  final GetKajianListUseCase _getKajianListUseCase;

  UstadzDetailBloc(
    this._getKajianListUseCase,
  ) : super(const UstadzDetailState()) {
    on<LoadKajianByUstadz>(_onLoadKajianByUstadz);
  }

  Future<void> _onLoadKajianByUstadz(
    LoadKajianByUstadz event,
    Emitter<UstadzDetailState> emit,
  ) async {
    if (state.hasReachedMax) return;
    emit(state.copyWith(
      statusKajian: FormzSubmissionStatus.inProgress,
    ));
    final kajianRequest = KajianScheduleRequestModel(
      page: event.page,
      options: [
        'filter,ustadz.ustadz_id,equal,${event.ustadzId}',
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
