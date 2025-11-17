import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/features/pray/domain/entities/prayer.codegen.dart';
import 'package:quranku/features/pray/domain/usecases/get_prayer_detail_usecase.dart';
import 'package:quranku/features/pray/domain/usecases/get_prayers_usecase.dart';

part 'prayer_detail_bloc.freezed.dart';
part 'prayer_detail_event.dart';
part 'prayer_detail_state.dart';

@injectable
class PrayerDetailBloc extends Bloc<PrayerDetailEvent, PrayerDetailState> {
  final GetPrayerDetailUsecase _getPrayerDetailUsecase;
  final GetPrayersUsecase _getPrayersUsecase;

  PrayerDetailBloc(
    this._getPrayerDetailUsecase,
    this._getPrayersUsecase,
  ) : super(const PrayerDetailState()) {
    on<_LoadPrayerDetail>(_onLoadPrayerDetail);
    on<_LoadSuggestedPrayers>(_onLoadSuggestedPrayers);
  }

  Future<void> _onLoadPrayerDetail(
    _LoadPrayerDetail event,
    Emitter<PrayerDetailState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    final result = await _getPrayerDetailUsecase(
      GetPrayerDetailParams(id: event.id),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: 'Failed to load prayer detail',
      )),
      (prayer) {
        emit(state.copyWith(
          status: FormzSubmissionStatus.success,
          prayer: prayer,
        ));
        add(const PrayerDetailEvent.loadSuggestedPrayers());
      },
    );
  }

  Future<void> _onLoadSuggestedPrayers(
    _LoadSuggestedPrayers event,
    Emitter<PrayerDetailState> emit,
  ) async {
    emit(state.copyWith(
        suggestedPrayersStatus: FormzSubmissionStatus.inProgress));

    final result = await _getPrayersUsecase(const GetPrayersParams(limit: 6));

    result.fold(
      (failure) => emit(state.copyWith(
        suggestedPrayersStatus: FormzSubmissionStatus.failure,
      )),
      (prayers) {
        // Filter out the current prayer if it exists in the list
        final filteredPrayers = prayers
            .where(
              (prayer) => prayer.id != state.prayer?.id,
            )
            .take(5)
            .toList();

        emit(state.copyWith(
          suggestedPrayersStatus: FormzSubmissionStatus.success,
          suggestedPrayers: filteredPrayers,
        ));
      },
    );
  }
}
