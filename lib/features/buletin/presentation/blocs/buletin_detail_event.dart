part of 'buletin_detail_bloc.dart';

@freezed
abstract class BuletinDetailEvent with _$BuletinDetailEvent {
  const factory BuletinDetailEvent.loadBuletinDetail(int id) =
      _LoadBuletinDetail;
}
