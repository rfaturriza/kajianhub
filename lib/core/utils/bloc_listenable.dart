import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlocListenable<B extends StateStreamable<S>, S> extends ChangeNotifier {
  final B _bloc;
  late final StreamSubscription<S> _subscription;

  BlocListenable(
    this._bloc, {
    bool Function(S previous, S current)? whenListen,
  }) {
    _subscription = _bloc.stream
        .where((event) => whenListen?.call(_bloc.state, event) ?? true)
        .listen(
      (_) {
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
