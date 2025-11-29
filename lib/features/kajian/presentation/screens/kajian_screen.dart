import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';
import 'package:quranku/core/components/search_box.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/core/utils/extension/extension.dart';
import 'package:quranku/core/utils/extension/string_ext.dart';
import 'package:quranku/features/kajian/domain/entities/day_kajian.codegen.dart';
import 'package:quranku/features/kajian/domain/entities/kajian_type.codegen.dart';
import 'package:quranku/features/kajian/domain/entities/prayer_kajian.codegen.dart';
import 'package:quranku/generated/locale_keys.g.dart';

import '../../../../core/components/error_screen.dart';
import '../../../../core/components/spacer.dart';
import '../../../../core/utils/pair.dart';
import '../../domain/entities/week_kajian.codegen.dart';
import '../bloc/kajian/kajian_bloc.dart';
import '../components/item_bottom_sheet.dart';
import '../components/kajian_tile.dart';

class KajianScreen extends StatelessWidget {
  const KajianScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const VSpacer(height: 10),
        BlocBuilder<KajianBloc, KajianState>(
          buildWhen: (previous, current) => previous.search != current.search,
          builder: (context, state) {
            return SearchBox(
              initialValue: state.search ?? emptyString,
              hintText: LocaleKeys.searchKajianHint.tr(),
              onClear: () {
                context.read<KajianBloc>().add(
                      KajianEvent.fetchKajian(
                        pageNumber: 1,
                        locale: context.locale,
                        search: emptyString,
                      ),
                    );
              },
              onSubmitted: (value) {
                context.read<KajianBloc>().add(
                      KajianEvent.fetchKajian(
                        pageNumber: 1,
                        locale: context.locale,
                        search: value,
                      ),
                    );
              },
            );
          },
        ),
        const VSpacer(height: 10),
        const _FilterRowSection(),
        Expanded(
          child: BlocConsumer<KajianBloc, KajianState>(
            listenWhen: (previous, current) {
              return previous.status != current.status &&
                  current.status.isFailure &&
                  current.kajianResult.isNotEmpty;
            },
            listener: (context, state) {
              if (state.status.isFailure && state.kajianResult.isNotEmpty) {
                context.showErrorToast(
                  LocaleKeys.errorGetKajian.tr(),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state.status.isInProgress;
              if (state.status.isFailure && state.kajianResult.isEmpty) {
                return ErrorScreen(
                  message: state.kajianErrorMessage ??
                      LocaleKeys.errorGetKajian.tr(),
                  onRefresh: () {
                    context.read<KajianBloc>().add(
                          KajianEvent.fetchKajian(
                            locale: context.locale,
                            pageNumber: 1,
                          ),
                        );
                  },
                );
              }
              if (state.kajianResult.isEmpty && !isLoading) {
                return ErrorScreen(
                  message: LocaleKeys.searchKajianEmpty.tr(),
                );
              }
              return NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (scrollNotification.metrics.pixels ==
                          scrollNotification.metrics.maxScrollExtent &&
                      !isLoading &&
                      state.kajianResult.isNotEmpty) {
                    context.read<KajianBloc>().add(
                          KajianEvent.fetchKajian(
                            locale: context.locale,
                            pageNumber: state.currentPage + 1,
                          ),
                        );
                  }
                  return true;
                },
                child: ListView.builder(
                  itemCount: isLoading
                      ? state.kajianResult.length + 1
                      : state.kajianResult.length,
                  itemBuilder: (context, index) {
                    if (isLoading && index == state.kajianResult.length) {
                      return const Center(
                        child: LinearProgressIndicator(),
                      );
                    }
                    return KajianTile(
                      key: Key(index.toString()),
                      kajian: state.kajianResult.elementAt(index),
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

class _FilterRowSection extends StatelessWidget {
  const _FilterRowSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 9,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  BlocBuilder<KajianBloc, KajianState>(
                    buildWhen: (previous, current) =>
                        previous.filter.isNearby != current.filter.isNearby,
                    builder: (context, state) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: _filterChip(
                          context: context,
                          label: LocaleKeys.nearby.tr(),
                          selected: state.filter.isNearby,
                          onSelected: (_) {
                            context.read<KajianBloc>().add(
                                  const KajianEvent.toggleNearby(),
                                );
                          },
                        ),
                      );
                    },
                  ),
                  BlocBuilder<KajianBloc, KajianState>(
                    buildWhen: (previous, current) =>
                        previous.filter != current.filter,
                    builder: (context, state) {
                      return Row(
                        children: [
                          if (state.filter.date != null) ...[
                            _filterChip(
                              context: context,
                              label: state.filter.date
                                      ?.ddMMMMyyyy(context.locale) ??
                                  emptyString,
                              onSelected: (_) {
                                context.read<KajianBloc>().add(
                                      const KajianEvent.onChangeFilterDate(
                                        null,
                                      ),
                                    );
                              },
                            ),
                          ],
                          if (state.filter.kajianTypeId != null) ...[
                            _filterChip(
                              context: context,
                              label: state.filter.kajianTypeId!.first,
                              onSelected: (_) {
                                context.read<KajianBloc>().add(
                                      const KajianEvent.onChangeKajianTypeId(
                                        null,
                                      ),
                                    );
                              },
                            ),
                          ],
                          if (state.filter.studyLocationProvinceId != null) ...[
                            _filterChip(
                              context: context,
                              label:
                                  state.filter.studyLocationProvinceId!.first,
                              onSelected: (_) {
                                context.read<KajianBloc>().add(
                                      const KajianEvent.onChangeFilterProvince(
                                          null),
                                    );
                              },
                            ),
                          ],
                          if (state.filter.studyLocationCityId != null) ...[
                            _filterChip(
                              context: context,
                              label: state.filter.studyLocationCityId!.first,
                              onSelected: (_) {
                                context.read<KajianBloc>().add(
                                      const KajianEvent.onChangeFilterCity(
                                        null,
                                      ),
                                    );
                              },
                            ),
                          ],
                          if (state.filter.locationId != null) ...[
                            _filterChip(
                              context: context,
                              label: state.filter.locationId!.first,
                              onSelected: (_) {
                                context.read<KajianBloc>().add(
                                      const KajianEvent.onChangeFilterMosque(
                                        null,
                                      ),
                                    );
                              },
                            ),
                          ],
                          if (state.filter.dailySchedulesDayId != null) ...[
                            _filterChip(
                              context: context,
                              label: state.filter.dailySchedulesDayId!.first,
                              onSelected: (_) {
                                context.read<KajianBloc>().add(
                                      const KajianEvent
                                          .onChangeDailySchedulesDayId(
                                        null,
                                      ),
                                    );
                              },
                            ),
                          ],
                          if (state.filter.weeklySchedulesWeekId != null) ...[
                            _filterChip(
                              context: context,
                              label: state.filter.weeklySchedulesWeekId!.first,
                              onSelected: (_) {
                                context.read<KajianBloc>().add(
                                      const KajianEvent
                                          .onChangeWeeklySchedulesWeekId(
                                        null,
                                      ),
                                    );
                              },
                            ),
                          ],
                          if (state.filter.prayerSchedule != null) ...[
                            _filterChip(
                              context: context,
                              label: state.filter.prayerSchedule!.first,
                              onSelected: (_) {
                                context.read<KajianBloc>().add(
                                      const KajianEvent.onChangePrayerSchedule(
                                        null,
                                      ),
                                    );
                              },
                            ),
                          ],
                          if (state.filter.themesThemeId != null) ...[
                            _filterChip(
                              context: context,
                              label: state.filter.themesThemeId!.first,
                              onSelected: (_) {
                                context.read<KajianBloc>().add(
                                      const KajianEvent.onChangeFilterTheme(
                                        null,
                                      ),
                                    );
                              },
                            ),
                          ],
                          if (state.filter.ustadzUstadzId != null) ...[
                            _filterChip(
                              context: context,
                              label: state.filter.ustadzUstadzId!.first,
                              onSelected: (_) {
                                context.read<KajianBloc>().add(
                                      const KajianEvent.onChangeFilterUstadz(
                                        null,
                                      ),
                                    );
                              },
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
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
                final filterBefore = context.read<KajianBloc>().state.filter;
                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  enableDrag: true,
                  builder: (_) => BlocProvider.value(
                    value: context.read<KajianBloc>()
                      ..add(
                        const KajianEvent.fetchKajianThemes(),
                      )
                      ..add(
                        const KajianEvent.fetchProvinces(),
                      )
                      ..add(
                        const KajianEvent.fetchCities(),
                      )
                      ..add(
                        const KajianEvent.fetchMosques(),
                      )
                      ..add(
                        const KajianEvent.fetchUstadz(),
                      ),
                    child: DraggableScrollableSheet(
                      initialChildSize: 0.7,
                      minChildSize: 0.5,
                      maxChildSize: 0.9,
                      expand: false,
                      builder: (context, scrollController) {
                        return _KajianBottomSheetFilter(
                          scrollController: scrollController,
                        );
                      },
                    ),
                  ),
                ).whenComplete(() {
                  if (context.mounted) {
                    final filterAfter = context.read<KajianBloc>().state.filter;
                    if (filterBefore != filterAfter) {
                      context.read<KajianBloc>().add(
                            KajianEvent.fetchKajian(
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
        ],
      ),
    );
  }

  Widget _filterChip({
    required BuildContext context,
    required String label,
    bool selected = true,
    required void Function(bool) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: FilterChip(
        label: Text(label.splitMapJoin('|', onMatch: (m) => ', ')),
        selected: selected,
        onSelected: (bool value) {
          onSelected(value);
          context.read<KajianBloc>().add(
                KajianEvent.fetchKajian(
                  locale: context.locale,
                  pageNumber: 1,
                ),
              );
        },
      ),
    );
  }
}

class _KajianBottomSheetFilter extends StatelessWidget {
  final ScrollController scrollController;

  const _KajianBottomSheetFilter({
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
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
                      visible:
                          context.watch<KajianBloc>().state.filter.isNotEmpty,
                      child: TextButton(
                        onPressed: () {
                          context.read<KajianBloc>().add(
                                const KajianEvent.resetFilter(),
                              );
                          context.read<KajianBloc>().add(
                                KajianEvent.fetchKajian(
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
                const _DatePickerSection(),
                const VSpacer(height: 10),
                const _KajianTypeSection(),
                const VSpacer(height: 10),
                const _ProvinceFilterSection(),
                const VSpacer(height: 10),
                const _CityFilterSection(),
                const VSpacer(height: 10),
                const _MosqueFilterSection(),
                const VSpacer(height: 10),
                const _DayFilterSection(),
                const VSpacer(height: 10),
                const _WeekFilterSection(),
                const VSpacer(height: 10),
                const _PrayerFilterSection(),
                const VSpacer(height: 10),
                const _ThemeFilterSection(),
                const VSpacer(height: 10),
                const _UstadzFilterSection(),
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
                context.read<KajianBloc>().add(
                      KajianEvent.fetchKajian(
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

class _DatePickerSection extends StatelessWidget {
  const _DatePickerSection();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<KajianBloc>();
    return BlocBuilder<KajianBloc, KajianState>(
      buildWhen: (previous, current) {
        return previous.filter.date != current.filter.date;
      },
      builder: (context, state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                LocaleKeys.kajianDateSchedule.tr(),
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const VSpacer(height: 8),
            GestureDetector(
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: state.filter.date ?? DateTime.now(),
                  firstDate:
                      DateTime.now().subtract(const Duration(days: 365 * 5)),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                );
                if (selectedDate != null) {
                  bloc.add(
                    KajianEvent.onChangeFilterDate(
                      selectedDate,
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: context.theme.colorScheme.onSurface, width: 0.5),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.date_range_outlined,
                      color: context.theme.colorScheme.onSurface,
                    ),
                    const HSpacer(width: 5),
                    Expanded(
                      child: Text(
                        state.filter.date?.ddMMMMyyyy(context.locale) ??
                            LocaleKeys.selectDate.tr(),
                        style: context.textTheme.bodyMedium,
                      ),
                    ),
                    state.filter.date != null
                        ? InkWell(
                            onTap: () {
                              context.read<KajianBloc>().add(
                                    const KajianEvent.onChangeFilterDate(
                                      null,
                                    ),
                                  );
                            },
                            child: const Icon(Icons.close),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
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
    return BlocBuilder<KajianBloc, KajianState>(
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
              context.read<KajianBloc>().add(
                    const KajianEvent.fetchProvinces(),
                  );
            },
          );
        }
        return ItemOnBottomSheet(
          title: LocaleKeys.province.tr(),
          selected: state.filter.studyLocationProvinceId,
          isMultipleSelect: false,
          items: state.provinces
              .map((e) => Pair(e.name, e.id.toString()))
              .toList(),
          isLoading: state.provincesStatus.isInProgress,
          onSelected: (value) {
            context.read<KajianBloc>().add(
                  KajianEvent.onChangeFilterProvince(
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
    return BlocBuilder<KajianBloc, KajianState>(
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
              context.read<KajianBloc>().add(
                    const KajianEvent.fetchCities(),
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
            context.read<KajianBloc>().add(
                  KajianEvent.onChangeFilterCity(
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
    return BlocBuilder<KajianBloc, KajianState>(
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
        if (state.mosquesStatus.isFailure) {
          return ErrorScreen(
            message: LocaleKeys.errorGetMosque.tr(),
            onRefresh: () {
              context.read<KajianBloc>().add(
                    const KajianEvent.fetchMosques(),
                  );
            },
          );
        }
        var items = state.mosques
            .map((e) => Pair(e.name.orEmpty(), e.id.toString()))
            .toList();
        final selectedProvinceId = state.filter.studyLocationProvinceId;
        if (selectedProvinceId != null) {
          items = state.mosques
              .where(
                  (e) => e.province?.id.toString() == selectedProvinceId.second)
              .map((e) => Pair(e.name.orEmpty(), e.id.toString()))
              .toList();
        }
        final selectedCityId = state.filter.studyLocationCityId;
        if (selectedCityId != null) {
          items = state.mosques
              .where((e) => e.city?.id.toString() == selectedCityId.second)
              .map((e) => Pair(e.name.orEmpty(), e.id.toString()))
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
            context.read<KajianBloc>().add(
                  KajianEvent.onChangeFilterMosque(
                    value,
                  ),
                );
          },
        );
      },
    );
  }
}

class _DayFilterSection extends StatelessWidget {
  const _DayFilterSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KajianBloc, KajianState>(
      buildWhen: (previous, current) {
        return previous.filter.dailySchedulesDayId !=
            current.filter.dailySchedulesDayId;
      },
      builder: (context, state) {
        return ItemOnBottomSheet(
          title: LocaleKeys.day.tr(),
          isShowAllButton: false,
          selected: state.filter.dailySchedulesDayId,
          items: DayKajian.days.map((e) => Pair(e.name, e.id)).toList(),
          onSelected: (value) {
            context.read<KajianBloc>().add(
                  KajianEvent.onChangeDailySchedulesDayId(
                    value,
                  ),
                );
          },
        );
      },
    );
  }
}

class _KajianTypeSection extends StatelessWidget {
  const _KajianTypeSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KajianBloc, KajianState>(
      buildWhen: (previous, current) {
        return previous.filter.kajianTypeId != current.filter.kajianTypeId;
      },
      builder: (context, state) {
        return ItemOnBottomSheet(
          title: LocaleKeys.kajianType.tr(),
          isShowAllButton: false,
          selected: state.filter.kajianTypeId,
          items: KajianType.types.map((e) => Pair(e.name, e.id)).toList(),
          onSelected: (value) {
            context.read<KajianBloc>().add(
                  KajianEvent.onChangeKajianTypeId(
                    value,
                  ),
                );
          },
        );
      },
    );
  }
}

class _WeekFilterSection extends StatelessWidget {
  const _WeekFilterSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KajianBloc, KajianState>(
      buildWhen: (previous, current) {
        return previous.filter.weeklySchedulesWeekId !=
            current.filter.weeklySchedulesWeekId;
      },
      builder: (context, state) {
        return ItemOnBottomSheet(
          title: LocaleKeys.week.tr(),
          isShowAllButton: false,
          selected: state.filter.weeklySchedulesWeekId,
          items: WeekKajian.weeks.map((e) => Pair(e.name, e.id)).toList(),
          onSelected: (value) {
            context.read<KajianBloc>().add(
                  KajianEvent.onChangeWeeklySchedulesWeekId(
                    value,
                  ),
                );
          },
        );
      },
    );
  }
}

class _PrayerFilterSection extends StatelessWidget {
  const _PrayerFilterSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KajianBloc, KajianState>(
      buildWhen: (previous, current) {
        return previous.filter.prayerSchedule != current.filter.prayerSchedule;
      },
      builder: (context, state) {
        return ItemOnBottomSheet(
          title: LocaleKeys.prayerSchedule.tr(),
          isShowAllButton: false,
          selected: state.filter.prayerSchedule,
          items: PrayerKajian.prayersByLocale(context.locale)
              .map((e) => Pair(e.name, e.id))
              .toList(),
          onSelected: (value) {
            context.read<KajianBloc>().add(
                  KajianEvent.onChangePrayerSchedule(
                    value,
                  ),
                );
          },
        );
      },
    );
  }
}

class _ThemeFilterSection extends StatelessWidget {
  const _ThemeFilterSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KajianBloc, KajianState>(
      buildWhen: (previous, current) {
        return previous.kajianThemes != current.kajianThemes ||
            previous.filter.themesThemeId != current.filter.themesThemeId ||
            previous.kajianThemesStatus != current.kajianThemesStatus;
      },
      builder: (context, state) {
        if (state.kajianThemesStatus.isFailure) {
          return ErrorScreen(
            message: LocaleKeys.errorGetKajianTheme.tr(),
            onRefresh: () {
              context.read<KajianBloc>().add(
                    const KajianEvent.fetchKajianThemes(),
                  );
            },
          );
        }
        return ItemOnBottomSheet(
          title: LocaleKeys.theme.tr(),
          selected: state.filter.themesThemeId,
          isLoading: state.kajianThemesStatus.isInProgress,
          items:
              state.kajianThemes.map((e) => Pair(e.theme, e.themeId)).toList(),
          onSelected: (value) {
            context.read<KajianBloc>().add(
                  KajianEvent.onChangeFilterTheme(
                    value,
                  ),
                );
          },
        );
      },
    );
  }
}

class _UstadzFilterSection extends StatelessWidget {
  const _UstadzFilterSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KajianBloc, KajianState>(
      buildWhen: (previous, current) {
        return previous.ustadz != current.ustadz ||
            previous.filter.ustadzUstadzId != current.filter.ustadzUstadzId ||
            previous.ustadzStatus != current.ustadzStatus;
      },
      builder: (context, state) {
        if (state.ustadzStatus.isFailure) {
          return ErrorScreen(
            message: LocaleKeys.errorGetUstadz.tr(),
            onRefresh: () {
              context.read<KajianBloc>().add(
                    const KajianEvent.fetchUstadz(),
                  );
            },
          );
        }
        return ItemOnBottomSheet(
          title: LocaleKeys.ustadz.tr(),
          countShow: 3,
          selected: state.filter.ustadzUstadzId,
          isLoading: state.ustadzStatus.isInProgress,
          items:
              state.ustadz.map((e) => Pair(e.name, e.id.toString())).toList(),
          onSelected: (value) {
            context.read<KajianBloc>().add(
                  KajianEvent.onChangeFilterUstadz(
                    value,
                  ),
                );
          },
        );
      },
    );
  }
}
