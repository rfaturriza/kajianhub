import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quranku/core/utils/extension/string_ext.dart';
import 'package:quranku/features/payment/domain/entities/transaction_midtrans.codegen.dart';

part 'transaction_response_model.codegen.freezed.dart';

part 'transaction_response_model.codegen.g.dart';

@freezed
abstract class TransactionResponseModel with _$TransactionResponseModel {
  const factory TransactionResponseModel({
    String? token,
    @JsonKey(name: "redirect_url") String? redirectUrl,
  }) = _TransactionResponseModel;

  const TransactionResponseModel._();

  factory TransactionResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionResponseModelFromJson(json);

  TransactionMidtrans toEntity() => TransactionMidtrans(
        token: token ?? emptyString,
        redirectUrl: redirectUrl ?? emptyString,
      );
}
