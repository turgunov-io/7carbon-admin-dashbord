import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/request_state.dart';
import '../../../core/network/api_error.dart';
import '../data/portfolio_items_repository.dart';
import '../models/portfolio_item.dart';

class PortfolioItemsState extends Equatable {
  const PortfolioItemsState({
    required this.status,
    required this.items,
    this.message,
  });

  const PortfolioItemsState.initial()
    : status = RequestStatus.initial,
      items = const <PortfolioItem>[],
      message = null;

  final RequestStatus status;
  final List<PortfolioItem> items;
  final String? message;

  PortfolioItemsState copyWith({
    RequestStatus? status,
    List<PortfolioItem>? items,
    String? message,
    bool clearMessage = false,
  }) {
    return PortfolioItemsState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: clearMessage ? null : message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, items, message];
}

class PortfolioItemsCubit extends Cubit<PortfolioItemsState> {
  PortfolioItemsCubit(this._repository)
    : super(const PortfolioItemsState.initial());

  final PortfolioItemsRepository _repository;
  int _localIdSeed = -1;

  Future<void> load() async {
    emit(state.copyWith(status: RequestStatus.loading, clearMessage: true));

    try {
      final items = await _repository.fetchPortfolioItems();
      emit(
        state.copyWith(
          status: RequestStatus.success,
          items: items,
          clearMessage: true,
        ),
      );
    } on ApiError catch (error) {
      emit(
        state.copyWith(status: RequestStatus.failure, message: error.message),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: RequestStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }

  int nextLocalId() {
    final id = _localIdSeed;
    _localIdSeed -= 1;
    return id;
  }

  void addLocal(PortfolioItem item) {
    emit(state.copyWith(items: [item, ...state.items]));
  }

  void updateLocal(PortfolioItem updated) {
    final items = state.items
        .map((item) => item.id == updated.id ? updated : item)
        .toList(growable: false);
    emit(state.copyWith(items: items));
  }
}
