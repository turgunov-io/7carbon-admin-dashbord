import 'package:flutter_bloc/flutter_bloc.dart';

import '../network/api_error.dart';
import 'request_state.dart';

typedef RequestLoader<T> = Future<T> Function();

class RequestCubit<T> extends Cubit<RequestState<T>> {
  RequestCubit(this._loader) : super(const RequestState.initial());

  final RequestLoader<T> _loader;

  Future<void> load() async {
    emit(RequestState.loading(data: state.data));

    try {
      final data = await _loader();
      emit(RequestState.success(data));
    } on ApiError catch (error) {
      emit(RequestState.failure(error.message, data: state.data));
    } catch (error) {
      emit(RequestState.failure(error.toString(), data: state.data));
    }
  }
}
