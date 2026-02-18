import '../models/admin_entity_item.dart';

enum AdminLoadStatus { initial, loading, success, failure }

class AdminEntityState {
  const AdminEntityState({
    required this.status,
    required this.items,
    this.errorMessage,
    this.submitting = false,
  });

  const AdminEntityState.initial()
    : status = AdminLoadStatus.initial,
      items = const <AdminEntityItem>[],
      errorMessage = null,
      submitting = false;

  final AdminLoadStatus status;
  final List<AdminEntityItem> items;
  final String? errorMessage;
  final bool submitting;

  AdminEntityState copyWith({
    AdminLoadStatus? status,
    List<AdminEntityItem>? items,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? submitting,
  }) {
    return AdminEntityState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      submitting: submitting ?? this.submitting,
    );
  }
}
