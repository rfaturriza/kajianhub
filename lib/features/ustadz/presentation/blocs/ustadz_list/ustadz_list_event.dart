part of 'ustadz_list_bloc.dart';

abstract class UstadzListEvent extends Equatable {
  const UstadzListEvent();

  @override
  List<Object?> get props => [];
}

class LoadUstadzList extends UstadzListEvent {
  final String? querySearch;
  final Locale locale;
  final int page;

  const LoadUstadzList({
    this.querySearch,
    required this.locale,
    this.page = 1,
  });

  @override
  List<Object?> get props => [querySearch, locale, page];
}
