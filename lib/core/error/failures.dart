import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';

import '../../generated/locale_keys.g.dart';

abstract class Failure extends Equatable {
  final String? message;
  const Failure({this.message});
  
  String get errorMessage => message ?? LocaleKeys.defaultErrorMessage.tr();
  
  @override
  List<Object> get props => [errorMessage];
}

class ServerFailure extends Failure {
  const ServerFailure({super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message});
}

class GeneralFailure extends Failure {
  const GeneralFailure({super.message});
}

String mapFailureToMessage(Failure failure) {
  switch (failure.runtimeType) {
    case ServerFailure _:
      return failure.message ?? LocaleKeys.defaultErrorMessage.tr();
    case CacheFailure _:
      return failure.message ?? LocaleKeys.defaultErrorMessage.tr();
    default:
      return 'Unexpected error';
  }
}