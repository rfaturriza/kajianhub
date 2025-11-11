import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';
import 'package:quranku/core/components/error_screen.dart';
import 'package:quranku/core/components/search_box.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/core/utils/extension/extension.dart';
import 'package:quranku/core/utils/extension/string_ext.dart';
import 'package:quranku/generated/locale_keys.g.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/components/spacer.dart';
import '../../../../core/utils/pair.dart';
import '../../domain/entities/prayer_kajian.codegen.dart';
import '../bloc/prayerSchedule/prayer_schedule_bloc.dart';
import '../components/item_bottom_sheet.dart';
import '../components/label_tag.dart';
import '../components/mosque_image_container.dart';
import '../components/schedule_icon_text.dart';

class KajianPrayerScheduleScreen extends StatelessWidget {
  const KajianPrayerScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const VSpacer(height: 10),
        const _SchedulePrayerRowSection(),
        const VSpacer(height: 10),
        BlocBuilder<PrayerScheduleBloc, PrayerScheduleState>(
          buildWhen: (previous, current) {
            return previous.search != current.search;
          },
          builder: (context, state) {
            return SearchBox(
              initialValue: state.search ?? emptyString,
              hintText: LocaleKeys.searchRamadhanHint.tr(),
              onClear: () {
                context.read<PrayerScheduleBloc>().add(
                      PrayerScheduleEvent.fetchPrayerKajianSchedules(
                        locale: context.locale,
                        pageNumber: 1,
                        search: emptyString,
                      ),
                    );
              },
              onSubmitted: (value) {
                context.read<PrayerScheduleBloc>().add(
                      PrayerScheduleEvent.fetchPrayerKajianSchedules(
                        locale: context.locale,
                        pageNumber: 1,
                        search: value,
                      ),
                    );
              },
            );
          },
        ),
        const VSpacer(height: 10),
        const _FilterRowSection(),
        const VSpacer(height: 10),
        Expanded(
          child: BlocConsumer<PrayerScheduleBloc, PrayerScheduleState>(
            listenWhen: (previous, current) {
              return previous.status != current.status &&
                  current.status.isFailure &&
                  current.prayerKajianSchedules.isNotEmpty;
            },
            listener: (context, state) {
              if (state.status.isFailure &&
                  state.prayerKajianSchedules.isNotEmpty) {
                context.showErrorToast(
                  LocaleKeys.errorGetRamadhanSchedule.tr(),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state.status.isInProgress;
              if (state.status.isFailure &&
                  state.prayerKajianSchedules.isEmpty) {
                return ErrorScreen(
                  message: LocaleKeys.errorGetRamadhanSchedule.tr(),
                  onRefresh: () {
                    context.read<PrayerScheduleBloc>().add(
                          PrayerScheduleEvent.fetchPrayerKajianSchedules(
                            locale: context.locale,
                            pageNumber: 1,
                          ),
                        );
                  },
                );
              }
              if (state.prayerKajianSchedules.isEmpty && !isLoading) {
                return ErrorScreen(
                  message: LocaleKeys.searchRamadhanEmpty.tr(),
                );
              }
              return NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (scrollNotification.metrics.pixels ==
                          scrollNotification.metrics.maxScrollExtent &&
                      !isLoading &&
                      state.prayerKajianSchedules.isNotEmpty) {
                    context.read<PrayerScheduleBloc>().add(
                          PrayerScheduleEvent.fetchPrayerKajianSchedules(
                            locale: context.locale,
                            pageNumber: state.currentPage + 1,
                          ),
                        );
                  }
                  return true;
                },
                child: ListView.builder(
                  itemCount: isLoading
                      ? state.prayerKajianSchedules.length + 1
                      : state.prayerKajianSchedules.length,
                  itemBuilder: (context, index) {
                    if (isLoading &&
                        index == state.prayerKajianSchedules.length) {
                      return const Center(
                        child: LinearProgressIndicator(),
                      );
                    }
                    final schedule = state.prayerKajianSchedules[index];
                    return _RamadhanTile(
                      imageUrl:
                          schedule.studyLocation?.pictureUrl ?? emptyString,
                      prayerName: schedule.subtypeLabel ?? emptyString,
                      title: schedule.studyLocation?.name ?? emptyString,
                      imam: schedule.imam ?? emptyString,
                      khatib: schedule.khatib ?? emptyString,
                      date: schedule.prayDate ?? emptyString,
                      place: schedule.studyLocation?.address ?? emptyString,
                      urlGoogleMaps:
                          schedule.studyLocation?.googleMaps ?? emptyString,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SchedulePrayerRowSection extends StatelessWidget {
  const _SchedulePrayerRowSection();

  @override
  Widget build(BuildContext context) {
    void setPrayerAndReFetch(
      String id,
      String name,
      DateTime selectedDate,
    ) {
      context.read<PrayerScheduleBloc>().add(
            PrayerScheduleEvent.onChangeFilterPrayDate(
              selectedDate,
            ),
          );
      context.read<PrayerScheduleBloc>().add(
            PrayerScheduleEvent.onChangeFilterSubtype(
              Pair(name, id),
            ),
          );
      context.read<PrayerScheduleBloc>().add(
            PrayerScheduleEvent.fetchPrayerKajianSchedules(
              locale: context.locale,
              pageNumber: 1,
            ),
          );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: BlocBuilder<PrayerScheduleBloc, PrayerScheduleState>(
          builder: (context, state) {
            return Row(
              children: PrayerKajian.prayersKajian()
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: FilterChip(
                        label: Text(e.name),
                        selected: state.filter.prayerSchedule?.second == e.id,
                        onSelected: (bool value) {
                          final isJumah = e.id == '1:';
                          final now = DateTime.now();
                          var selectedDate = now;
                          if (isJumah && value) {
                            selectedDate = () {
                              if (now.weekday == DateTime.friday) {
                                return now;
                              }
                              if (now.weekday < DateTime.friday) {
                                return now.add(
                                  Duration(days: DateTime.friday - now.weekday),
                                );
                              }
                              if (now.weekday > DateTime.friday) {
                                return now.add(
                                  Duration(
                                    days: DateTime.friday - now.weekday + 7,
                                  ),
                                );
                              }
                              return now;
                            }();
                          }
                          setPrayerAndReFetch(e.id, e.name, selectedDate);
                        },
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}

class _FilterRowSection extends StatelessWidget {
  const _FilterRowSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 20,
        children: [
          Expanded(
            flex: 8,
            child: _DatePickerSection(),
          ),
          Expanded(
            flex: 1,
            child: Badge.count(
              count:
                  context.watch<PrayerScheduleBloc>().state.filter.totalActive,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(4),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: context.theme.colorScheme.tertiary,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  foregroundColor: context.theme.colorScheme.tertiary,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                onPressed: () {
                  final filterBefore =
                      context.read<PrayerScheduleBloc>().state.filter;
                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    enableDrag: true,
                    builder: (_) => BlocProvider.value(
                      value: context.read<PrayerScheduleBloc>()
                        ..add(
                          const PrayerScheduleEvent.fetchProvinces(),
                        )
                        ..add(
                          const PrayerScheduleEvent.fetchCities(),
                        )
                        ..add(
                          const PrayerScheduleEvent.fetchMosques(),
                        ),
                      child: DraggableScrollableSheet(
                        initialChildSize: 0.7,
                        minChildSize: 0.5,
                        maxChildSize: 0.9,
                        expand: false,
                        builder: (context, scrollController) {
                          return _PrayerScheduleBottomSheetFilter(
                            scrollController: scrollController,
                          );
                        },
                      ),
                    ),
                  ).whenComplete(() {
                    if (context.mounted) {
                      final filterAfter =
                          context.read<PrayerScheduleBloc>().state.filter;
                      if (filterBefore != filterAfter) {
                        context.read<PrayerScheduleBloc>().add(
                              PrayerScheduleEvent.fetchPrayerKajianSchedules(
                                locale: context.locale,
                                pageNumber: 1,
                              ),
                            );
                      }
                    }
                  });
                },
                child: const Icon(
                  Icons.settings_input_composite_outlined,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePickerSection extends StatelessWidget {
  const _DatePickerSection();

  @override
  Widget build(BuildContext context) {
    void setDateAndReFetch(DateTime date) {
      context.read<PrayerScheduleBloc>().add(
            PrayerScheduleEvent.onChangeFilterPrayDate(date),
          );
      context.read<PrayerScheduleBloc>().add(
            PrayerScheduleEvent.fetchPrayerKajianSchedules(
              locale: context.locale,
              pageNumber: 1,
            ),
          );
    }

    return BlocBuilder<PrayerScheduleBloc, PrayerScheduleState>(
      buildWhen: (previous, current) {
        return previous.filter.prayDate != current.filter.prayDate ||
            previous.filter.prayerSchedule != current.filter.prayerSchedule;
      },
      builder: (context, state) {
        final setFriday = () {
          final now = DateTime.now();
          if (now.weekday == DateTime.friday) {
            return now;
          }
          if (now.weekday < DateTime.friday) {
            return now.add(
              Duration(days: DateTime.friday - now.weekday),
            );
          }
          if (now.weekday > DateTime.friday) {
            return now.add(
              Duration(
                days: DateTime.friday - now.weekday + 7,
              ),
            );
          }
          return now;
        }();
        final daysDiff = () {
          final selectedDate = state.filter.prayDate;
          final isFriday = selectedDate?.weekday == DateTime.friday;
          final isFridaySelected = state.filter.prayerSchedule?.second ==
              PrayerKajian.prayersKajian()
                  .where((e) => e.name == 'Jum\'at')
                  .first
                  .id;
          final duration = () {
            if (isFriday && isFridaySelected) {
              return 7;
            }
            return 1;
          }();
          return duration;
        }();
        return Row(
          children: [
            Expanded(
              flex: 1,
              child: IconButton(
                onPressed: () {
                  final selectedDate = state.filter.prayDate;
                  if (selectedDate != null) {
                    final substractDuration = daysDiff;
                    setDateAndReFetch(
                      selectedDate.subtract(
                        Duration(days: substractDuration),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.arrow_back_ios),
              ),
            ),
            Expanded(
              flex: 8,
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity != 0) {
                    final selectedDate = state.filter.prayDate;
                    if (selectedDate != null) {
                      final duration = daysDiff;
                      setDateAndReFetch(
                        selectedDate.add(
                          Duration(
                            days: (details.primaryVelocity ?? 0) > 0
                                ? -duration
                                : duration,
                          ),
                        ),
                      );
                    }
                  }
                },
                onTap: () async {
                  final now = DateTime.now();
                  final isFridaySelected =
                      state.filter.prayerSchedule?.second ==
                          PrayerKajian.prayersKajian()
                              .where((e) => e.name == 'Jum\'at')
                              .first
                              .id;
                  final initialDate = () {
                    if (isFridaySelected) {
                      return setFriday;
                    }
                    return state.filter.prayDate ?? now;
                  }();

                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: initialDate,
                    firstDate: now.subtract(const Duration(days: 365 * 5)),
                    lastDate: now.add(const Duration(days: 365 * 5)),
                    selectableDayPredicate: (day) {
                      if (isFridaySelected) {
                        return day.weekday == DateTime.friday;
                      }
                      return true;
                    },
                  );
                  if (selectedDate != null && context.mounted) {
                    setDateAndReFetch(selectedDate);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: context.theme.colorScheme.onSurface,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text(
                    textAlign: TextAlign.center,
                    state.filter.prayDate?.ddMMMMyyyy(context.locale) ??
                        LocaleKeys.selectDate.tr(),
                    style: context.textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                onPressed: () {
                  final selectedDate = state.filter.prayDate;
                  if (selectedDate != null) {
                    final addDuration = daysDiff;
                    setDateAndReFetch(
                      selectedDate.add(
                        Duration(days: addDuration),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.arrow_forward_ios),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RamadhanTile extends StatelessWidget {
  final String imageUrl;
  final String prayerName;
  final String title;
  final String imam;
  final String khatib;
  final String date;
  final String place;
  final String urlGoogleMaps;

  const _RamadhanTile({
    required this.imageUrl,
    required this.prayerName,
    required this.title,
    required this.imam,
    required this.khatib,
    required this.date,
    required this.place,
    required this.urlGoogleMaps,
  });

  @override
  Widget build(BuildContext context) {
    final scheduledDate = DateTime.parse(date).toEEEEddMMMMyyyy(context.locale);
    final Pair<Color, Color> prayerColor = () {
      switch (prayerName.toLowerCase()) {
        case 'subuh':
          return Pair(
            context.theme.colorScheme.tertiaryContainer,
            context.theme.colorScheme.onTertiaryContainer,
          );
        case 'terawih':
          return Pair(
            context.theme.colorScheme.secondaryContainer,
            context.theme.colorScheme.onSecondaryContainer,
          );
        default:
          return Pair(
            context.theme.colorScheme.primaryContainer,
            context.theme.colorScheme.onPrimaryContainer,
          );
      }
    }();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: ShapeDecoration(
        color: context.theme.colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MosqueImageContainer(
            imageUrl: imageUrl,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LabelTag(
                          title: prayerName,
                          backgroundColor: prayerColor.first,
                          foregroundColor: prayerColor.second,
                        ),
                        Text(
                          title,
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const VSpacer(height: 2),
                        RichText(
                            text: TextSpan(children: [
                          TextSpan(
                            text: '${LocaleKeys.imam.tr()}: ',
                            style: context.textTheme.bodySmall,
                          ),
                          TextSpan(
                            text: imam,
                            style: context.textTheme.bodySmall,
                          ),
                        ])),
                        const VSpacer(height: 2),
                        RichText(
                            text: TextSpan(children: [
                          TextSpan(
                            text: '${LocaleKeys.khatib.tr()}: ',
                            style: context.textTheme.bodySmall,
                          ),
                          TextSpan(
                            text: khatib,
                            style: context.textTheme.bodySmall,
                          ),
                        ])),
                        const VSpacer(height: 2),
                        ScheduleIconText(
                          icon: Icons.date_range_outlined,
                          text: scheduledDate ?? emptyString,
                        ),
                        const VSpacer(height: 2),
                        InkWell(
                          onTap: () async {
                            final uri = Uri.parse(urlGoogleMaps);
                            if (!await launchUrl(uri)) {
                              if (context.mounted) {
                                context.showErrorToast(
                                  LocaleKeys.errorOpenMap.tr(),
                                );
                              }
                            }
                          },
                          child: Shimmer.fromColors(
                            baseColor: context.theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                            highlightColor: context.theme.colorScheme.onSurface,
                            period: const Duration(seconds: 10),
                            child: ScheduleIconText(
                              icon: Icons.place_outlined,
                              text: place,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerScheduleBottomSheetFilter extends StatelessWidget {
  final ScrollController scrollController;

  const _PrayerScheduleBottomSheetFilter({
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    return SafeArea(
      minimum: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        LocaleKeys.filter.tr(),
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: context
                          .watch<PrayerScheduleBloc>()
                          .state
                          .filter
                          .isNotEmpty(),
                      child: TextButton(
                        onPressed: () {
                          context.read<PrayerScheduleBloc>().add(
                                const PrayerScheduleEvent.resetFilter(),
                              );
                          context.read<PrayerScheduleBloc>().add(
                                PrayerScheduleEvent.fetchPrayerKajianSchedules(
                                  locale: context.locale,
                                  pageNumber: 1,
                                ),
                              );
                          context.pop();
                        },
                        child: Text(
                          LocaleKeys.reset.tr(),
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const VSpacer(height: 10),
                const _SwitchNearbySection(),
                const VSpacer(height: 10),
                const _ProvinceFilterSection(),
                const VSpacer(height: 10),
                const _CityFilterSection(),
                const VSpacer(height: 10),
                const _MosqueFilterSection(),
                const VSpacer(height: 10),
                const _SearchImamSection(),
                const VSpacer(height: 10),
                const _SearchKhatibSection(),
                const VSpacer(height: 10),
              ],
            ),
          ),
          Container(
            color: context.theme.colorScheme.surface,
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
                backgroundColor: context.theme.colorScheme.onPrimary,
                foregroundColor: context.theme.colorScheme.primary,
              ),
              onPressed: () {
                context.read<PrayerScheduleBloc>().add(
                      PrayerScheduleEvent.fetchPrayerKajianSchedules(
                        locale: context.locale,
                        pageNumber: 1,
                      ),
                    );
                context.pop();
              },
              child: Text(LocaleKeys.apply.tr()),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchNearbySection extends StatelessWidget {
  const _SwitchNearbySection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerScheduleBloc, PrayerScheduleState>(
      buildWhen: (previous, current) {
        return previous.filter.isNearby != current.filter.isNearby;
      },
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LocaleKeys.nearby.tr(),
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Switch(
              value: state.filter.isNearby,
              onChanged: (value) {
                context.read<PrayerScheduleBloc>().add(
                      const PrayerScheduleEvent.toggleNearby(),
                    );
              },
            ),
          ],
        );
      },
    );
  }
}

class _ProvinceFilterSection extends StatelessWidget {
  const _ProvinceFilterSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerScheduleBloc, PrayerScheduleState>(
      buildWhen: (previous, current) {
        return previous.provinces != current.provinces ||
            previous.filter.studyLocationProvinceId !=
                current.filter.studyLocationProvinceId ||
            previous.provincesStatus != current.provincesStatus;
      },
      builder: (context, state) {
        if (state.provincesStatus.isFailure) {
          return ErrorScreen(
            message: LocaleKeys.errorGetProvince.tr(),
            onRefresh: () {
              context.read<PrayerScheduleBloc>().add(
                    const PrayerScheduleEvent.fetchProvinces(),
                  );
            },
          );
        }
        return ItemOnBottomSheet(
          title: LocaleKeys.province.tr(),
          selected: state.filter.studyLocationProvinceId,
          isMultipleSelect: false,
          isLoading: state.provincesStatus.isInProgress,
          items: state.provinces
              .map((e) => Pair(e.name, e.id.toString()))
              .toList(),
          onSelected: (value) {
            context.read<PrayerScheduleBloc>().add(
                  PrayerScheduleEvent.onChangeFilterProvince(
                    value,
                  ),
                );
          },
        );
      },
    );
  }
}

class _CityFilterSection extends StatelessWidget {
  const _CityFilterSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerScheduleBloc, PrayerScheduleState>(
      buildWhen: (previous, current) {
        return previous.cities != current.cities ||
            previous.filter.studyLocationCityId !=
                current.filter.studyLocationCityId ||
            previous.citiesStatus != current.citiesStatus ||
            previous.filter.studyLocationProvinceId !=
                current.filter.studyLocationProvinceId;
      },
      builder: (context, state) {
        if (state.citiesStatus.isFailure) {
          return ErrorScreen(
            message: LocaleKeys.errorGetCity.tr(),
            onRefresh: () {
              context.read<PrayerScheduleBloc>().add(
                    const PrayerScheduleEvent.fetchCities(),
                  );
            },
          );
        }
        final selectedProvinceId = state.filter.studyLocationProvinceId;
        var items =
            state.cities.map((e) => Pair(e.name, e.id.toString())).toList();
        if (selectedProvinceId != null) {
          items = items
              .where((e) => e.second.startsWith(selectedProvinceId.second))
              .toList();
        }
        return ItemOnBottomSheet(
          title: LocaleKeys.city.tr(),
          selected: state.filter.studyLocationCityId,
          isMultipleSelect: false,
          isLoading: state.citiesStatus.isInProgress,
          items: items,
          onSelected: (value) {
            context.read<PrayerScheduleBloc>().add(
                  PrayerScheduleEvent.onChangeFilterCity(
                    value,
                  ),
                );
          },
        );
      },
    );
  }
}

class _MosqueFilterSection extends StatelessWidget {
  const _MosqueFilterSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerScheduleBloc, PrayerScheduleState>(
      buildWhen: (previous, current) {
        return previous.mosques != current.mosques ||
            previous.filter.locationId != current.filter.locationId ||
            previous.mosquesStatus != current.mosquesStatus ||
            previous.filter.studyLocationCityId !=
                current.filter.studyLocationCityId ||
            previous.filter.studyLocationProvinceId !=
                current.filter.studyLocationProvinceId;
      },
      builder: (context, state) {
        if (state.mosquesStatus == FormzSubmissionStatus.failure) {
          return ErrorScreen(
            message: LocaleKeys.errorGetMosque.tr(),
            onRefresh: () {
              context.read<PrayerScheduleBloc>().add(
                    const PrayerScheduleEvent.fetchMosques(),
                  );
            },
          );
        }
        var items = state.mosques
            .map((e) => Pair(e.name?.orEmpty() ?? '', e.id?.toString() ?? ''))
            .toList();
        final selectedProvinceId = state.filter.studyLocationProvinceId;
        if (selectedProvinceId != null) {
          items = state.mosques
              .where((e) =>
                  (e as dynamic)?.province?.id?.toString() ==
                  selectedProvinceId.second)
              .map((e) => Pair(e.name?.orEmpty() ?? '', e.id?.toString() ?? ''))
              .toList();
        }
        final selectedCityId = state.filter.studyLocationCityId;
        if (selectedCityId != null) {
          items = state.mosques
              .where((e) => e.city?.id?.toString() == selectedCityId.second)
              .map((e) => Pair(e.name?.orEmpty() ?? '', e.id?.toString() ?? ''))
              .toList();
        }
        return ItemOnBottomSheet(
          title: LocaleKeys.mosque.tr(),
          isMultipleSelect: false,
          countShow: 3,
          selected: state.filter.locationId,
          isLoading: state.mosquesStatus.isInProgress,
          items: items,
          onSelected: (value) {
            context.read<PrayerScheduleBloc>().add(
                  PrayerScheduleEvent.onChangeFilterMosque(
                    value,
                  ),
                );
          },
        );
      },
    );
  }
}

class _SearchImamSection extends StatelessWidget {
  const _SearchImamSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerScheduleBloc, PrayerScheduleState>(
      buildWhen: (previous, current) {
        return previous.filter.imam != current.filter.imam;
      },
      builder: (context, state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                LocaleKeys.imam.tr(),
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const VSpacer(height: 8),
            SearchBox(
              borderRadius: BorderRadius.circular(4),
              padding: EdgeInsets.zero,
              border: Border.all(
                color: context.theme.colorScheme.onSurface,
                width: 0.5,
              ),
              initialValue: state.filter.imam ?? '',
              hintText: LocaleKeys.searchImamHint.tr(),
              onClear: () {
                context.read<PrayerScheduleBloc>().add(
                      const PrayerScheduleEvent.onChangeFilterImam(
                        null,
                      ),
                    );
              },
              onChanged: (value) {
                context.read<PrayerScheduleBloc>().add(
                      PrayerScheduleEvent.onChangeFilterImam(
                        value,
                      ),
                    );
              },
            ),
          ],
        );
      },
    );
  }
}

class _SearchKhatibSection extends StatelessWidget {
  const _SearchKhatibSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerScheduleBloc, PrayerScheduleState>(
      buildWhen: (previous, current) {
        return previous.filter.khatib != current.filter.khatib;
      },
      builder: (context, state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.khatib.tr(),
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const VSpacer(height: 5),
            SearchBox(
              borderRadius: BorderRadius.circular(4),
              padding: EdgeInsets.zero,
              border: Border.all(
                color: context.theme.colorScheme.onSurface,
                width: 0.5,
              ),
              initialValue: state.filter.khatib ?? '',
              hintText: LocaleKeys.searchKhatibHint.tr(),
              onClear: () {
                context.read<PrayerScheduleBloc>().add(
                      const PrayerScheduleEvent.onChangeFilterKhatib(
                        null,
                      ),
                    );
              },
              onChanged: (value) {
                context.read<PrayerScheduleBloc>().add(
                      PrayerScheduleEvent.onChangeFilterKhatib(
                        value,
                      ),
                    );
              },
            ),
          ],
        );
      },
    );
  }
}
