import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/request_state.dart';
import '../../../core/network/api_error.dart';
import '../data/work_posts_repository.dart';
import '../models/work_post_item.dart';

class WorkPostsState extends Equatable {
  const WorkPostsState({
    required this.status,
    required this.items,
    this.message,
  });

  const WorkPostsState.initial()
    : status = RequestStatus.initial,
      items = const <WorkPostItem>[],
      message = null;

  final RequestStatus status;
  final List<WorkPostItem> items;
  final String? message;

  WorkPostsState copyWith({
    RequestStatus? status,
    List<WorkPostItem>? items,
    String? message,
    bool clearMessage = false,
  }) {
    return WorkPostsState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: clearMessage ? null : message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, items, message];
}

class WorkPostsCubit extends Cubit<WorkPostsState> {
  WorkPostsCubit(this._repository) : super(const WorkPostsState.initial());

  final WorkPostsRepository _repository;
  int _localIdSeed = -1;

  Future<void> load() async {
    emit(state.copyWith(status: RequestStatus.loading, clearMessage: true));

    try {
      final items = await _repository.fetchWorkPosts();
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

  void addLocal(WorkPostItem item) {
    emit(state.copyWith(items: [item, ...state.items]));
  }

  void updateLocal(WorkPostItem updated) {
    final items = state.items
        .map((item) => item.id == updated.id ? updated : item)
        .toList(growable: false);
    emit(state.copyWith(items: items));
  }
}
