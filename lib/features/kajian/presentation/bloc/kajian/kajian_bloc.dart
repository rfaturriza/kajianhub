import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/core/utils/extension/dartz_ext.dart';
import 'package:quranku/core/utils/extension/extension.dart';
import 'package:quranku/features/kajian/domain/entities/filter_kajian_schedule.codegen.dart';
import 'package:quranku/features/kajian/domain/entities/kajian_schedule.codegen.dart';
import 'package:quranku/features/kajian/domain/usecases/get_ustadz_list_usecase.dart';
import 'package:quranku/features/ustadz/domain/entities/ustadz_entity.codegen.dart';

import '../../../../../core/utils/pair.dart';
import '../../../../shalat/domain/usecase/get_current_location_usecase.dart';
import '../../../data/models/kajian_schedule_request_model.codegen.dart';
import '../../../data/models/study_locations_response_model.codegen.dart';
import '../../../domain/usecases/get_cities_usecase.dart';
import '../../../domain/usecases/get_kajian_list_usecase.dart';
import '../../../domain/usecases/get_kajian_themes_usecase.dart';
import '../../../domain/usecases/get_mosques_usecase.dart';
import '../../../domain/usecases/get_nearby_kajian_list_usecase.dart';
import '../../../domain/usecases/get_provinces_usecase.dart';

part 'kajian_bloc.freezed.dart';
part 'kajian_event.dart';
part 'kajian_state.dart';

@injectable
class KajianBloc extends Bloc<KajianEvent, KajianState> {
  final GetKajianListUseCase _getKajianListUseCase;
  final GetCurrentLocationUseCase _getCurrentLocation;
  final GetNearbyKajianListUseCase _getNearbyKajianListUseCase;
  final GetKajianThemesUseCase _getKajianThemesUseCase;
  final GetProvincesUseCase _getProvincesUseCase;
  final GetCitiesUseCase _getCitiesUseCase;
  final GetMosquesUseCase _getMosquesUseCase;
  final GetUstadzListUseCase _getUstadzListUseCase;
  final FirebaseAnalytics _firebaseAnalytics;
  final int limit = 10;

  KajianBloc(
    this._getKajianListUseCase,
    this._getCurrentLocation,
    this._getNearbyKajianListUseCase,
    this._getKajianThemesUseCase,
    this._getProvincesUseCase,
    this._getCitiesUseCase,
    this._getMosquesUseCase,
    this._getUstadzListUseCase,
    this._firebaseAnalytics,
  ) : super(KajianState(
          filter: FilterKajianSchedule(
            date: DateTime.now(),
            isNearby: true,
          ),
        )) {
    _firebaseAnalytics.logScreenView(screenName: 'Kajian Screen');
    on<_FetchKajian>(_onFetchKajian);
    on<_FetchNearbyKajian>(_onFetchNearbyKajian);
    on<_ToggleNearby>(_onToggleNearby);
    on<_FetchKajianThemes>(_onFetchKajianThemes);
    on<_FetchProvinces>(_onFetchProvinces);
    on<_FetchCities>(_onFetchCities);
    on<_FetchMosques>(_onFetchMosques);
    on<_FetchUstadz>(_onFetchUstadz);
    on<_OnChangeFilterProvince>(_onChangeFilterProvince);
    on<_OnChangeFilterCity>(_onChangeFilterCity);
    on<_OnChangeFilterMosque>(_onChangeFilterMosque);
    on<_OnChangeFilterUstadz>(_onChangeFilterUstadz);
    on<_OnChangeFilterTheme>(_onChangeFilterTheme);
    on<_OnChangePrayerSchedule>(_onChangePrayerSchedule);
    on<_OnChangeDailySchedulesDayId>(_onChangeDailySchedulesDayId);
    on<_OnChangeWeeklySchedulesWeekId>(_onChangeWeeklySchedulesWeekId);
    on<_OnChangeFilterDate>(_onChangeFilterDate);
    on<_ResetFilter>(_onResetFilter);
  }

  void _onFetchKajian(_FetchKajian event, Emitter<KajianState> emit) async {
    if (state.lastPage != null && event.pageNumber > state.lastPage!) {
      return;
    }
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    if (event.pageNumber == 1) {
      emit(state.copyWith(kajianResult: []));
    }
    try {
      var request = KajianScheduleRequestModel(
        page: event.pageNumber,
        limit: limit,
      );
      if (state.filter.studyLocationProvinceId != null) {
        request = request.copyWith(
          options: [
            ...?request.options,
            'filter,studyLocation.province_id,in,${state.filter.studyLocationProvinceId!.second}',
          ],
        );
      }
      if (state.filter.studyLocationCityId != null) {
        request = request.copyWith(
          options: [
            ...?request.options,
            'filter,studyLocation.city_id,in,${state.filter.studyLocationCityId!.second}',
          ],
        );
      }
      if (state.filter.locationId != null) {
        request = request.copyWith(
          options: [
            ...?request.options,
            'filter,location_id,in,${state.filter.locationId!.second}',
          ],
        );
      }
      if (state.filter.dailySchedulesDayId != null) {
        request = request.copyWith(
          options: [
            ...?request.options,
            'filter,dailySchedules.day_id,in,${state.filter.dailySchedulesDayId!.second}',
          ],
        );
      }
      if (state.filter.weeklySchedulesWeekId != null) {
        request = request.copyWith(
          options: [
            ...?request.options,
            'filter,weeklySchedules.week_id,in,${state.filter.weeklySchedulesWeekId!.second}',
          ],
        );
      }
      if (state.filter.prayerSchedule != null) {
        request = request.copyWith(
          options: [
            ...?request.options,
            'filter,jadwal_shalat,in,${state.filter.prayerSchedule!.second}',
          ],
        );
      }
      if (state.filter.themesThemeId != null) {
        request = request.copyWith(
          options: [
            ...?request.options,
            'filter,themes.theme_id,in,${state.filter.themesThemeId!.second}',
          ],
        );
      }
      if (state.filter.ustadzUstadzId != null) {
        request = request.copyWith(
          options: [
            ...?request.options,
            'filter,ustadz.ustadz_id,in,${state.filter.ustadzUstadzId!.second}',
          ],
        );
      }
      if (state.filter.date != null) {
        request = request.copyWith(
          isByDate: 1,
          date: state.filter.date.yyyyMMdd,
          isDaily: 1,
        );
      }
      if (state.filter.isNearby) {
        final geoLocation = await _getCurrentLocation(
          GetCurrentLocationParams(locale: event.locale),
        );
        request = request.copyWith(
          latitude: geoLocation.asRight()?.coordinate?.lat ?? 0,
          longitude: geoLocation.asRight()?.coordinate?.lon ?? 0,
          isNearest: 1,
        );
      }
      if (event.search != null) {
        request = request.copyWith(
          query: event.search,
        );
        emit(state.copyWith(search: event.search));
      }
      _firebaseAnalytics.logEvent(
        name: 'fetch_kajian',
        parameters: request.toAnalytic(),
      );
      final result = await _getKajianListUseCase(request);
      result.fold(
        (failure) => emit(
          state.copyWith(
            status: FormzSubmissionStatus.failure,
            kajianErrorMessage: failure.errorMessage,
          ),
        ),
        (data) {
          final currentData = state.kajianResult;
          final newData = (currentData + data.data).toSet().toList();
          emit(state.copyWith(
            status: FormzSubmissionStatus.success,
            kajianResult: newData,
            currentPage: data.meta.currentPage ?? 0,
            lastPage: data.meta.lastPage ?? 0,
            totalData: data.meta.total ?? 0,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }

  void _onFetchNearbyKajian(
      _FetchNearbyKajian event, Emitter<KajianState> emit) async {
    emit(state.copyWith(statusRecommended: FormzSubmissionStatus.inProgress));
    try {
      final geoLocation = await Geolocator.getLastKnownPosition();

      final result = await _getNearbyKajianListUseCase(
        GetNearbyKajianListUseCaseParams(
          latitude: geoLocation?.latitude ?? 0,
          longitude: geoLocation?.longitude ?? 0,
        ),
      );
      result.fold(
        (failure) => emit(
          state.copyWith(statusRecommended: FormzSubmissionStatus.failure),
        ),
        (data) {
          emit(state.copyWith(
            statusRecommended: FormzSubmissionStatus.success,
            recommendedKajian: data.data.isNotEmpty ? data.data.first : null,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(statusRecommended: FormzSubmissionStatus.failure));
    }
  }

  void _onToggleNearby(_ToggleNearby event, Emitter<KajianState> emit) async {
    emit(state.copyWith(
      filter: state.filter.copyWith(isNearby: !state.filter.isNearby),
    ));
  }

  void _onFetchKajianThemes(
    _FetchKajianThemes event,
    Emitter<KajianState> emit,
  ) async {
    if (state.kajianThemes.isNotEmpty) {
      return;
    }
    emit(state.copyWith(kajianThemesStatus: FormzSubmissionStatus.inProgress));
    try {
      final result = await _getKajianThemesUseCase(
        const GetKajianThemesParams(),
      );
      result.fold(
        (failure) => emit(
          state.copyWith(kajianThemesStatus: FormzSubmissionStatus.failure),
        ),
        (data) {
          emit(state.copyWith(
            kajianThemesStatus: FormzSubmissionStatus.success,
            kajianThemes: data,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(kajianThemesStatus: FormzSubmissionStatus.failure));
    }
  }

  void _onFetchProvinces(
    _FetchProvinces event,
    Emitter<KajianState> emit,
  ) async {
    if (state.provinces.isNotEmpty) {
      return;
    }
    emit(state.copyWith(provincesStatus: FormzSubmissionStatus.inProgress));
    try {
      final result = await _getProvincesUseCase(
        const GetProvincesParams(),
      );
      result.fold(
        (failure) => emit(
          state.copyWith(provincesStatus: FormzSubmissionStatus.failure),
        ),
        (data) {
          emit(state.copyWith(
            provincesStatus: FormzSubmissionStatus.success,
            provinces: data,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(provincesStatus: FormzSubmissionStatus.failure));
    }
  }

  void _onFetchCities(
    _FetchCities event,
    Emitter<KajianState> emit,
  ) async {
    if (state.cities.isNotEmpty) {
      return;
    }
    emit(state.copyWith(citiesStatus: FormzSubmissionStatus.inProgress));
    try {
      final result = await _getCitiesUseCase(
        const GetCitiesParams(),
      );
      result.fold(
        (failure) => emit(
          state.copyWith(citiesStatus: FormzSubmissionStatus.failure),
        ),
        (data) {
          emit(state.copyWith(
            citiesStatus: FormzSubmissionStatus.success,
            cities: data,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(citiesStatus: FormzSubmissionStatus.failure));
    }
  }

  void _onFetchMosques(
    _FetchMosques event,
    Emitter<KajianState> emit,
  ) async {
    if (state.mosques.isNotEmpty) {
      return;
    }
    emit(state.copyWith(mosquesStatus: FormzSubmissionStatus.inProgress));
    try {
      final result = await _getMosquesUseCase(
        const GetMosquesParams(),
      );
      result.fold(
        (failure) => emit(
          state.copyWith(mosquesStatus: FormzSubmissionStatus.failure),
        ),
        (data) {
          emit(state.copyWith(
            mosquesStatus: FormzSubmissionStatus.success,
            mosques: data,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(mosquesStatus: FormzSubmissionStatus.failure));
    }
  }

  void _onFetchUstadz(
    _FetchUstadz event,
    Emitter<KajianState> emit,
  ) async {
    if (state.ustadz.isNotEmpty) {
      return;
    }
    emit(state.copyWith(ustadzStatus: FormzSubmissionStatus.inProgress));
    try {
      final result = await _getUstadzListUseCase(
        const GetUstadzListParams(),
      );
      result.fold(
        (failure) => emit(
          state.copyWith(ustadzStatus: FormzSubmissionStatus.failure),
        ),
        (data) {
          emit(state.copyWith(
            ustadzStatus: FormzSubmissionStatus.success,
            ustadz: data,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(ustadzStatus: FormzSubmissionStatus.failure));
    }
  }

  void _onChangeFilterProvince(
    _OnChangeFilterProvince event,
    Emitter<KajianState> emit,
  ) {
    if (event.filterProvince == null) {
      emit(
        state.copyWith(
          filter: state.filter.copyWith(
            studyLocationProvinceId: null,
          ),
        ),
      );
      return;
    }
    if (state.filter.studyLocationProvinceId?.second ==
        event.filterProvince?.second) {
      emit(
        state.copyWith(
          filter: state.filter.copyWith(
            studyLocationProvinceId: null,
          ),
        ),
      );
      return;
    }
    final filter = state.filter.copyWith(
      studyLocationProvinceId: event.filterProvince,
    );
    emit(state.copyWith(filter: filter));
  }

  void _onChangeFilterCity(
    _OnChangeFilterCity event,
    Emitter<KajianState> emit,
  ) {
    if (event.filterCity == null) {
      emit(
        state.copyWith(
          filter: state.filter.copyWith(
            studyLocationCityId: null,
          ),
        ),
      );
      return;
    }
    if (state.filter.studyLocationCityId?.second == event.filterCity?.second) {
      emit(
        state.copyWith(
          filter: state.filter.copyWith(
            studyLocationCityId: null,
          ),
        ),
      );
      return;
    }
    final filter = state.filter.copyWith(
      studyLocationCityId: event.filterCity,
    );
    emit(state.copyWith(filter: filter));
  }

  void _onChangeFilterMosque(
    _OnChangeFilterMosque event,
    Emitter<KajianState> emit,
  ) {
    if (event.filterMosque == null) {
      emit(
        state.copyWith(
          filter: state.filter.copyWith(
            locationId: null,
          ),
        ),
      );
      return;
    }
    if (state.filter.locationId?.second == event.filterMosque?.second) {
      emit(
        state.copyWith(
          filter: state.filter.copyWith(
            locationId: null,
          ),
        ),
      );
      return;
    }
    final filter = state.filter.copyWith(
      locationId: event.filterMosque,
    );
    emit(state.copyWith(filter: filter));
  }

  void _onChangeFilterUstadz(
    _OnChangeFilterUstadz event,
    Emitter<KajianState> emit,
  ) {
    if (event.filterUstadz == null) {
      emit(state.copyWith(filter: state.filter.copyWith(ustadzUstadzId: null)));
      return;
    }
    final currentFilter = state.filter.ustadzUstadzId;
    if (currentFilter != null) {
      final ustadzName = currentFilter.first.split('|');
      final ustadzId = currentFilter.second.split('|');
      if (ustadzId.contains(event.filterUstadz?.second)) {
        ustadzName.remove(event.filterUstadz?.first);
        ustadzId.remove(event.filterUstadz?.second);
      } else {
        ustadzName.add(event.filterUstadz!.first);
        ustadzId.add(event.filterUstadz!.second);
      }
      if (ustadzName.isEmpty) {
        emit(
          state.copyWith(
            filter: state.filter.copyWith(
              ustadzUstadzId: null,
            ),
          ),
        );
        return;
      }
      final filter = state.filter.copyWith(
        ustadzUstadzId: Pair(
          ustadzName.join('|'),
          ustadzId.join('|'),
        ),
      );
      emit(state.copyWith(filter: filter));
      return;
    }
    final filter = state.filter.copyWith(
      ustadzUstadzId: event.filterUstadz,
    );
    emit(state.copyWith(filter: filter));
  }

  void _onChangeFilterTheme(
    _OnChangeFilterTheme event,
    Emitter<KajianState> emit,
  ) {
    if (event.filterTheme == null) {
      emit(state.copyWith(filter: state.filter.copyWith(themesThemeId: null)));
      return;
    }
    final currentFilter = state.filter.themesThemeId;
    if (currentFilter != null) {
      final themesName = currentFilter.first.split('|');
      final themesId = currentFilter.second.split('|');
      if (themesId.contains(event.filterTheme?.second)) {
        themesName.remove(event.filterTheme?.first);
        themesId.remove(event.filterTheme?.second);
      } else {
        themesName.add(event.filterTheme!.first);
        themesId.add(event.filterTheme!.second);
      }
      if (themesName.isEmpty) {
        emit(
          state.copyWith(
            filter: state.filter.copyWith(
              themesThemeId: null,
            ),
          ),
        );
        return;
      }
      final filter = state.filter.copyWith(
        themesThemeId: Pair(
          themesName.toSet().toList().join('|'),
          themesId.toSet().toList().join('|'),
        ),
      );
      emit(state.copyWith(filter: filter));
      return;
    }
    final filter = state.filter.copyWith(
      themesThemeId: event.filterTheme,
    );
    emit(state.copyWith(filter: filter));
  }

  void _onChangePrayerSchedule(
    _OnChangePrayerSchedule event,
    Emitter<KajianState> emit,
  ) {
    if (event.prayerSchedule == null) {
      emit(state.copyWith(filter: state.filter.copyWith(prayerSchedule: null)));
      return;
    }

    final currentFilter = state.filter.prayerSchedule;
    if (currentFilter != null) {
      final prayerName = currentFilter.first.split('|');
      final prayerId = currentFilter.second.split('|');
      if (prayerId.contains(event.prayerSchedule?.second)) {
        prayerName.remove(event.prayerSchedule?.first);
        prayerId.remove(event.prayerSchedule?.second);
      } else {
        prayerName.add(event.prayerSchedule!.first);
        prayerId.add(event.prayerSchedule!.second);
      }
      if (prayerName.isEmpty) {
        emit(
          state.copyWith(
            filter: state.filter.copyWith(
              prayerSchedule: null,
            ),
          ),
        );
        return;
      }
      final filter = state.filter.copyWith(
        prayerSchedule: Pair(
          prayerName.join('|'),
          prayerId.join('|'),
        ),
      );
      emit(state.copyWith(filter: filter));
      return;
    }
    final filter = state.filter.copyWith(
      prayerSchedule: event.prayerSchedule,
    );
    emit(state.copyWith(filter: filter));
  }

  void _onChangeDailySchedulesDayId(
    _OnChangeDailySchedulesDayId event,
    Emitter<KajianState> emit,
  ) {
    if (event.dailySchedulesDayId == null) {
      emit(state.copyWith(
          filter: state.filter.copyWith(dailySchedulesDayId: null)));
      return;
    }

    final currentFilter = state.filter.dailySchedulesDayId;
    if (currentFilter != null) {
      final dayName = currentFilter.first.split('|');
      final dayId = currentFilter.second.split('|');
      if (dayId.contains(event.dailySchedulesDayId?.second)) {
        dayName.remove(event.dailySchedulesDayId?.first);
        dayId.remove(event.dailySchedulesDayId?.second);
      } else {
        dayName.add(event.dailySchedulesDayId!.first);
        dayId.add(event.dailySchedulesDayId!.second);
      }
      if (dayName.isEmpty) {
        emit(
          state.copyWith(
            filter: state.filter.copyWith(
              dailySchedulesDayId: null,
            ),
          ),
        );
        return;
      }
      final filter = state.filter.copyWith(
        dailySchedulesDayId: Pair(
          dayName.join('|'),
          dayId.join('|'),
        ),
      );
      emit(state.copyWith(filter: filter));
      return;
    }
    final filter = state.filter.copyWith(
      dailySchedulesDayId: event.dailySchedulesDayId,
    );
    emit(state.copyWith(filter: filter));
  }

  void _onChangeWeeklySchedulesWeekId(
    _OnChangeWeeklySchedulesWeekId event,
    Emitter<KajianState> emit,
  ) {
    if (event.weeklySchedulesWeekId == null) {
      emit(state.copyWith(
          filter: state.filter.copyWith(weeklySchedulesWeekId: null)));
      return;
    }

    final currentFilter = state.filter.weeklySchedulesWeekId;
    if (currentFilter != null) {
      final weekName = currentFilter.first.split('|');
      final weekId = currentFilter.second.split('|');
      if (weekId.contains(event.weeklySchedulesWeekId?.second)) {
        weekName.remove(event.weeklySchedulesWeekId?.first);
        weekId.remove(event.weeklySchedulesWeekId?.second);
      } else {
        weekName.add(event.weeklySchedulesWeekId!.first);
        weekId.add(event.weeklySchedulesWeekId!.second);
      }
      if (weekName.isEmpty) {
        emit(
          state.copyWith(
            filter: state.filter.copyWith(
              weeklySchedulesWeekId: null,
            ),
          ),
        );
        return;
      }
      final filter = state.filter.copyWith(
        weeklySchedulesWeekId: Pair(
          weekName.join('|'),
          weekId.join('|'),
        ),
      );
      emit(state.copyWith(filter: filter));
      return;
    }
    final filter = state.filter.copyWith(
      weeklySchedulesWeekId: event.weeklySchedulesWeekId,
    );
    emit(state.copyWith(filter: filter));
  }

  void _onChangeFilterDate(
    _OnChangeFilterDate event,
    Emitter<KajianState> emit,
  ) {
    emit(state.copyWith(filter: state.filter.copyWith(date: event.date)));
  }

  void _onResetFilter(
    _ResetFilter event,
    Emitter<KajianState> emit,
  ) {
    const filter = FilterKajianSchedule();
    emit(state.copyWith(filter: filter));
  }
}
