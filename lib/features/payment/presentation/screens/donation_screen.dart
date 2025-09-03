import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:quranku/core/components/expandable_webview.dart';
import 'package:quranku/core/components/loading_screen.dart';
import 'package:quranku/features/config/remote_config.dart';
import 'package:quranku/core/utils/extension/context_ext.dart';
import 'package:quranku/features/payment/presentation/bloc/in_app_purchase/in_app_purchase_bloc.dart';
import 'package:quranku/features/payment/presentation/bloc/midtrans/midtrans_bloc.dart';
import 'package:quranku/generated/locale_keys.g.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/components/button_drawer.dart';
import '../../../../injection.dart';
import '../../../quran/presentation/screens/components/app_bar_detail_screen.dart';

class DonationPaymentScreen extends StatelessWidget {
  const DonationPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => sl<MidtransBloc>(),
          ),
          BlocProvider(
            create: (context) => sl<InAppPurchaseBloc>()
              ..add(const InAppPurchaseEvent.initialize()),
          ),
        ],
        child: const _DonationPaymentScreen(),
      ),
    );
  }
}

class _DonationPaymentScreen extends StatelessWidget {
  const _DonationPaymentScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarDetailScreen(title: LocaleKeys.supportUs.tr()),
      body: BlocConsumer<InAppPurchaseBloc, InAppPurchaseState>(
        listener: (context, state) {
          if (state.purchaseStatus == PurchaseStatus.purchased) {
            context.showInfoToast(LocaleKeys.thankYouForYourSupport.tr());
          } else if (state.purchaseStatus == PurchaseStatus.error ||
              state.purchaseStatus == PurchaseStatus.canceled) {
            context.showErrorToast(LocaleKeys.donationFailedMessage.tr());
          } else if (state.purchaseStatus == PurchaseStatus.pending) {
            context.showInfoToast(LocaleKeys.donationInProgressMessage.tr());
          }
        },
        builder: (context, state) {
          if (state.purchaseStatus == PurchaseStatus.pending) {
            return const LoadingScreen();
          }
          return Column(
            children: [
              ExpandableWebView(
                sl<RemoteConfigService>().webViewDonationUrl,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  children: state.products
                      .map(
                        (e) => ListTile(
                          title: Text(e.title),
                          subtitle: Text(e.description),
                          trailing: Text(
                            e.price,
                            style: context.textTheme.titleMedium,
                          ),
                          onTap: () {
                            context
                                .read<InAppPurchaseBloc>()
                                .add(InAppPurchaseEvent.purchaseConsumable(e));
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ButtonDrawer(
            title: LocaleKeys.sincerelyDonation.tr(),
            onTap: () async {
              try {
                sl<FirebaseAnalytics>().logScreenView(
                  screenName: 'Saweria',
                );
                await launchUrl(
                  Uri.parse(sl<RemoteConfigService>().saweriaUrl),
                  mode: LaunchMode.inAppBrowserView,
                );
              } catch (e) {
                debugPrint(e.toString());
              }
            },
            icon: Icons.payments_rounded,
          ),
        ),
      ),
    );
  }
}
