import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/features/payment/data/models/transaction_request_model.codegen.dart';

part 'transaction_body_midtrans.codegen.freezed.dart';

@freezed
abstract class TransactionBodyMidtrans with _$TransactionBodyMidtrans {
  const factory TransactionBodyMidtrans({
    required int grossAmount,
    required String orderId,
    required bool secureCreditCard,
  }) = _TransactionBodyMidtrans;

  const TransactionBodyMidtrans._();

  TransactionRequestModel toModel() => TransactionRequestModel(
        transactionDetails: TransactionDetailsModel(
          orderId: orderId,
          grossAmount: grossAmount,
        ),
        creditCard: CreditCardModel(
          secure: secureCreditCard,
        ),
      );
}
