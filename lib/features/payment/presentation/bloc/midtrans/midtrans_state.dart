part of 'midtrans_bloc.dart';

@freezed
abstract class MidtransState with _$MidtransState {
  const factory MidtransState({
    @Default(FormzSubmissionStatus.initial) FormzSubmissionStatus status,
    Either<Failure, TransactionMidtrans?>? transaction,
    @Default(emptyString) String errorMessage,
  }) = _MidtransState;
}
