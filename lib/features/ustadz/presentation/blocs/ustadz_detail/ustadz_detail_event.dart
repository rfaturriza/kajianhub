part of 'ustadz_detail_bloc.dart';

abstract class UstadzDetailEvent extends Equatable {
  const UstadzDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadKajianByUstadz extends UstadzDetailEvent {
  final String ustadzId;
  final int page;

  const LoadKajianByUstadz({
    required this.ustadzId,
    this.page = 1,
  });

  @override
  List<Object?> get props => [ustadzId, page];
}
