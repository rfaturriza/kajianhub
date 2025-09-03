part of 'study_location_list_bloc.dart';

abstract class StudyLocationListEvent extends Equatable {
  const StudyLocationListEvent();

  @override
  List<Object?> get props => [];
}

class LoadMasjidList extends StudyLocationListEvent {
  final String? querySearch;
  final Locale locale;
  final int page;
  const LoadMasjidList({
    this.querySearch,
    required this.locale,
    this.page = 1,
  });

  @override
  List<Object?> get props => [querySearch, page];
}
