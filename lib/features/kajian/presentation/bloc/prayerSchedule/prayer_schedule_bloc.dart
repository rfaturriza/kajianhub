import 'dart:developer';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/core/utils/extension/dartz_ext.dart';

import '../../../../../core/utils/pair.dart';
import '../../../../shalat/domain/usecase/get_current_location_usecase.dart';
import '../../../data/models/study_locations_response_model.codegen.dart';
import '../../../data/models/prayer_kajian_schedule_request_model.codegen.dart';
import '../../../domain/entities/filter_prayer_schedule.codegen.dart';
import '../../../domain/entities/kajian_schedule.codegen.dart';
import '../../../domain/entities/prayer_kajian_schedules.codegen.dart';
import '../../../domain/usecases/get_cities_usecase.dart';
import '../../../domain/usecases/get_mosques_usecase.dart';
import '../../../domain/usecases/get_provinces_usecase.dart';
import '../../../domain/usecases/get_prayer_kajian_schedules_usecase.dart';

part 'prayer_schedule_bloc.freezed.dart';
part 'prayer_schedule_event.dart';
part 'prayer_schedule_state.dart';

@injectable
class PrayerScheduleBloc
    extends Bloc<PrayerScheduleEvent, PrayerScheduleState> {
  final GetPrayerKajianSchedulesUseCase _getPrayerKajianSchedulesUseCase;
  final GetCurrentLocationUseCase _getCurrentLocation;
  final GetProvincesUseCase _getProvincesUseCase;
  final GetCitiesUseCase _getCitiesUseCase;
  final GetMosquesUseCase _getMosquesUseCase;
  final FirebaseAnalytics _firebaseAnalytics;

  final int limit = 10;

  PrayerScheduleBloc(
    this._getPrayerKajianSchedulesUseCase,
    this._getCurrentLocation,
    this._getProvincesUseCase,
    this._getCitiesUseCase,
    this._getMosquesUseCase,
    this._firebaseAnalytics,
  ) : super(PrayerScheduleState(
          filter: FilterPrayerSchedule(
            prayDate: DateTime.now(),
            isNearby: true,
          ),
        )) {
    _firebaseAnalytics.logScreenView(screenName: 'Jadwal Ramadhan Screen');
    on<_FetchPrayerKajianSchedules>(_onFetchPrayerKajianSchedules);
    on<_ToggleNearby>(_onToggleNearby);
    on<_FetchProvinces>(_onFetchProvinces);
    on<_FetchCities>(_onFetchCities);
    on<_FetchMosques>(_onFetchMosques);
    on<_OnChangeFilterProvince>(_onChangeFilterProvince);
    on<_OnChangeFilterCity>(_onChangeFilterCity);
    on<_OnChangeFilterMosque>(_onChangeFilterMosque);
    on<_OnChangeFilterKhatib>(_onChangeFilterKhatib);
    on<_OnChangeFilterImam>(_onChangeFilterImam);
    on<_OnChangeFilterPrayDate>(_onChangeFilterPrayDate);
    on<_OnChangeFilterSubtype>(_onChangeFilterSubtype);
    on<_ResetFilter>(_onResetFilter);
  }

  void _onFetchPrayerKajianSchedules(
    _FetchPrayerKajianSchedules event,
    Emitter<PrayerScheduleState> emit,
  ) async {
    if (state.lastPage != null && event.pageNumber > state.lastPage!) {
      return;
    }
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    if (event.pageNumber == 1) {
      emit(state.copyWith(prayerKajianSchedules: []));
    }
    try {
      var request = PrayerKajianScheduleRequestModel(
        type: 'pagination',
        page: event.pageNumber,
        limit: limit,
        orderBy: 'pray_date',
        sortBy: 'desc',
        relations: 'studyLocation',
        options: [],
      );
      if (state.filter.studyLocationProvinceId != null) {
        request = request.copyWith(
          options: [
            ...?request.options,
            'filter,studyLocation.province_id,equal,${state.filter.studyLocationProvinceId!.second}',
          ],
        );
      }
      if (state.filter.studyLocationCityId != null) {
        request = request.copyWith(
          options: [
            ...?request.options,
            'filter,studyLocation.city_id,equal,${state.filter.studyLocationCityId!.second}',
          ],
        );
      }
      if (state.filter.locationId != null) {
        request = request.copyWith(
          options: [
            ...?request.options,
            'filter,location_id,equal,${state.filter.locationId!.second}',
          ],
        );
      }
      if (state.filter.prayerSchedule != null) {
        final splitId = state.filter.prayerSchedule?.second.split(':');
        final type =
            (splitId != null && splitId.isNotEmpty) ? splitId[0] : null;
        final subtype =
            (splitId != null && splitId.length > 1) ? splitId[1] : null;
        final options = [
          ...?request.options,
        ];

        if (type != null && type.isNotEmpty) {
          options.add('filter,type_id,equal,$type');
        }
        if (subtype != null && subtype.isNotEmpty) {
          options.add('filter,subtype_id,equal,$subtype');
        }

        request = request.copyWith(
          options: options,
        );
      }
      if (state.filter.khatib != null) {
        request = request.copyWith(
          options: [
            ...?request.options,
            'search,khatib,${state.filter.khatib}',
          ],
        );
      }
      if (state.filter.imam != null) {
        request = request.copyWith(
          options: [
            ...?request.options,
            'search,imam,${state.filter.imam}',
          ],
        );
      }
      if (state.filter.prayDate != null) {
        final date = DateFormat('yyyy-MM-dd').format(state.filter.prayDate!);
        request = request.copyWith(
          options: [
            ...?request.options,
            'filter,pray_date,equal,$date',
          ],
          prayDate: date,
        );
      }
      if (event.search != null) {
        request = request.copyWith(
          query: event.search,
        );
        emit(state.copyWith(search: event.search));
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
      _firebaseAnalytics.logEvent(
        name: 'fetch_ramadhan_schedules',
        parameters: request.toAnalytic(),
      );
      final result = await _getPrayerKajianSchedulesUseCase(
        request,
      );
      result.fold(
        (failure) => emit(
          state.copyWith(status: FormzSubmissionStatus.failure),
        ),
        (data) {
          final currentData = state.prayerKajianSchedules;
          final newData = (currentData + (data?.data ?? [])).toSet().toList();
          emit(state.copyWith(
            status: FormzSubmissionStatus.success,
            prayerKajianSchedules: newData,
            currentPage: data?.meta.currentPage ?? 0,
            totalData: data?.meta.total ?? 0,
            lastPage: data?.meta.lastPage ?? 0,
          ));
        },
      );
    } catch (e) {
      log('Error: $e', name: 'PrayerScheduleBloc');
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }

  void _onToggleNearby(
    _ToggleNearby event,
    Emitter<PrayerScheduleState> emit,
  ) async {
    emit(state.copyWith(
      filter: state.filter.copyWith(isNearby: !state.filter.isNearby),
    ));
  }

  void _onFetchProvinces(
    _FetchProvinces event,
    Emitter<PrayerScheduleState> emit,
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
    Emitter<PrayerScheduleState> emit,
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
    Emitter<PrayerScheduleState> emit,
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

  void _onChangeFilterProvince(
    _OnChangeFilterProvince event,
    Emitter<PrayerScheduleState> emit,
  ) async {
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
    Emitter<PrayerScheduleState> emit,
  ) async {
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
    Emitter<PrayerScheduleState> emit,
  ) async {
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

  void _onChangeFilterKhatib(
    _OnChangeFilterKhatib event,
    Emitter<PrayerScheduleState> emit,
  ) async {
    emit(state.copyWith(
      filter: state.filter.copyWith(khatib: event.filterKhatib),
    ));
  }

  void _onChangeFilterImam(
    _OnChangeFilterImam event,
    Emitter<PrayerScheduleState> emit,
  ) async {
    emit(state.copyWith(
      filter: state.filter.copyWith(imam: event.filterImam),
    ));
  }

  void _onChangeFilterPrayDate(
    _OnChangeFilterPrayDate event,
    Emitter<PrayerScheduleState> emit,
  ) async {
    emit(state.copyWith(
      filter: state.filter.copyWith(prayDate: event.prayDate),
    ));
  }

  void _onChangeFilterSubtype(
    _OnChangeFilterSubtype event,
    Emitter<PrayerScheduleState> emit,
  ) async {
    if (event.filterSubtype == null) {
      emit(
        state.copyWith(
          filter: state.filter.copyWith(
            prayerSchedule: null,
          ),
        ),
      );
      return;
    }
    if (state.filter.prayerSchedule?.second == event.filterSubtype?.second) {
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
      prayerSchedule: event.filterSubtype,
    );
    emit(state.copyWith(filter: filter));
  }

  void _onResetFilter(
    _ResetFilter event,
    Emitter<PrayerScheduleState> emit,
  ) async {
    emit(state.copyWith(
      filter: const FilterPrayerSchedule(),
    ));
  }
}
