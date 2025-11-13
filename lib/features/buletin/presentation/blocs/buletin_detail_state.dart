part of 'buletin_detail_bloc.dart';

@freezed
abstract class BuletinDetailState with _$BuletinDetailState {
  const factory BuletinDetailState({
    @Default(FormzSubmissionStatus.initial) FormzSubmissionStatus status,
    Buletin? buletin,
    String? errorMessage,
  }) = _BuletinDetailState;
}
