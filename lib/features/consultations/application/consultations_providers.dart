import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/request_state.dart';
import '../../../core/network/api_error.dart';
import '../data/consultations_repository.dart';
import '../models/consultation_create_request.dart';
import '../models/consultation_item.dart';
import '../models/consultation_status.dart';

class ConsultationsState extends Equatable {
  const ConsultationsState({
    required this.listStatus,
    required this.items,
    required this.filter,
    required this.creating,
    this.listError,
    this.createError,
  });

  const ConsultationsState.initial()
    : listStatus = RequestStatus.initial,
      items = const <ConsultationItem>[],
      filter = null,
      creating = false,
      listError = null,
      createError = null;

  final RequestStatus listStatus;
  final List<ConsultationItem> items;
  final ConsultationStatus? filter;
  final bool creating;
  final String? listError;
  final String? createError;

  ConsultationsState copyWith({
    RequestStatus? listStatus,
    List<ConsultationItem>? items,
    ConsultationStatus? filter,
    bool clearFilter = false,
    bool? creating,
    String? listError,
    bool clearListError = false,
    String? createError,
    bool clearCreateError = false,
  }) {
    return ConsultationsState(
      listStatus: listStatus ?? this.listStatus,
      items: items ?? this.items,
      filter: clearFilter ? null : filter ?? this.filter,
      creating: creating ?? this.creating,
      listError: clearListError ? null : listError ?? this.listError,
      createError: clearCreateError ? null : createError ?? this.createError,
    );
  }

  @override
  List<Object?> get props => [
    listStatus,
    items,
    filter,
    creating,
    listError,
    createError,
  ];
}

class ConsultationsCubit extends Cubit<ConsultationsState> {
  ConsultationsCubit(this._repository)
    : super(const ConsultationsState.initial());

  final ConsultationsRepository _repository;

  Future<void> load() async {
    emit(
      state.copyWith(listStatus: RequestStatus.loading, clearListError: true),
    );

    try {
      final items = await _repository.fetchConsultations(status: state.filter);
      emit(
        state.copyWith(
          listStatus: RequestStatus.success,
          items: items,
          clearListError: true,
        ),
      );
    } on ApiError catch (error) {
      emit(
        state.copyWith(
          listStatus: RequestStatus.failure,
          listError: error.message,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          listStatus: RequestStatus.failure,
          listError: error.toString(),
        ),
      );
    }
  }

  Future<void> setFilter(ConsultationStatus? filter) async {
    emit(state.copyWith(filter: filter));
    await load();
  }

  Future<bool> createConsultation(ConsultationCreateRequest request) async {
    emit(state.copyWith(creating: true, clearCreateError: true));

    try {
      await _repository.createConsultation(request);
      emit(state.copyWith(creating: false, clearCreateError: true));
      await load();
      return true;
    } on ApiError catch (error) {
      emit(state.copyWith(creating: false, createError: _createMessage(error)));
      return false;
    } catch (error) {
      emit(
        state.copyWith(
          creating: false,
          createError: 'Неожиданная ошибка: $error',
        ),
      );
      return false;
    }
  }

  void updateLocal(ConsultationItem updated) {
    final items = state.items
        .map((item) => item.id == updated.id ? updated : item)
        .toList(growable: false);
    emit(state.copyWith(items: items));
  }

  String _createMessage(ApiError error) {
    final code = error.statusCode == null ? '' : 'Код ${error.statusCode}: ';
    return '$code${error.message}';
  }
}
