part of 'last_read_cubit.dart';

@freezed
abstract class LastReadState with _$LastReadState {
  const factory LastReadState({
    @Default(FormzSubmissionStatus.initial) FormzSubmissionStatus statusJuz,
    @Default(FormzSubmissionStatus.initial) FormzSubmissionStatus statusSurah,
    @Default([]) List<LastReadSurah> lastReadSurah,
    @Default([]) List<LastReadJuz> lastReadJuz,
  }) = _LastReadState;
}
