import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:quranku/features/buletin/domain/entities/buletin.codegen.dart';
import 'package:quranku/features/buletin/domain/usecases/get_buletin_detail_usecase.dart';

part 'buletin_detail_event.dart';
part 'buletin_detail_state.dart';
part 'buletin_detail_bloc.freezed.dart';

@injectable
class BuletinDetailBloc extends Bloc<BuletinDetailEvent, BuletinDetailState> {
  final GetBuletinDetailUsecase _getBuletinDetailUsecase;

  BuletinDetailBloc(
    this._getBuletinDetailUsecase,
  ) : super(const BuletinDetailState()) {
    on<_LoadBuletinDetail>(_onLoadBuletinDetail);
  }

  Future<void> _onLoadBuletinDetail(
    _LoadBuletinDetail event,
    Emitter<BuletinDetailState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

    final result = await _getBuletinDetailUsecase(event.id);

    result.fold(
      (failure) => emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
        errorMessage: failure.message,
      )),
      (buletin) => emit(state.copyWith(
        status: FormzSubmissionStatus.success,
        buletin: buletin,
      )),
    );
  }
}
