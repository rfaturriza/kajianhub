part of 'in_app_purchase_bloc.dart';

@freezed
abstract class InAppPurchaseEvent with _$InAppPurchaseEvent {
  const factory InAppPurchaseEvent.streamPurchaseEvent(
    List<PurchaseDetails> purchaseDetails,
  ) = _StreamPurchaseEvent;

  const factory InAppPurchaseEvent.initialize() = _Initialize;

  const factory InAppPurchaseEvent.purchaseConsumable(
    ProductDetails productDetails,
  ) = _PurchaseConsumable;

  const factory InAppPurchaseEvent.purchaseNonConsumable(
    ProductDetails productDetails,
  ) = _PurchaseNonConsumable;

  const factory InAppPurchaseEvent.purchaseSubscription() =
      _PurchaseSubscription;
}
