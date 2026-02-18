import 'package:equatable/equatable.dart';

enum RequestStatus { initial, loading, success, failure }

class RequestState<T> extends Equatable {
  const RequestState({required this.status, this.data, this.message});

  const RequestState.initial()
    : status = RequestStatus.initial,
      data = null,
      message = null;

  const RequestState.loading({this.data})
    : status = RequestStatus.loading,
      message = null;

  const RequestState.success(T this.data)
    : status = RequestStatus.success,
      message = null;

  const RequestState.failure(this.message, {this.data})
    : status = RequestStatus.failure;

  final RequestStatus status;
  final T? data;
  final String? message;

  bool get isLoading => status == RequestStatus.loading;
  bool get isSuccess => status == RequestStatus.success;
  bool get isFailure => status == RequestStatus.failure;

  @override
  List<Object?> get props => [status, data, message];
}
