part of 'in_app_purchase_bloc.dart';

@freezed
abstract class InAppPurchaseState with _$InAppPurchaseState {
  const factory InAppPurchaseState({
    @Default(FormzSubmissionStatus.initial) FormzSubmissionStatus initStatus,
    @Default(PurchaseStatus.restored) PurchaseStatus purchaseStatus,
    @Default(false) bool isAvailable,
    @Default([]) List<PurchaseDetails> purchases,
    @Default([]) List<ProductDetails> products,
    @Default(emptyString) String errorMessage,
  }) = _InAppPurchaseState;
}
