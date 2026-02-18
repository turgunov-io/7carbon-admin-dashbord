enum ConsultationStatus { newRequest, inProgress, completed }

extension ConsultationStatusX on ConsultationStatus {
  String get apiValue {
    switch (this) {
      case ConsultationStatus.newRequest:
        return 'new';
      case ConsultationStatus.inProgress:
        return 'in_progress';
      case ConsultationStatus.completed:
        return 'completed';
    }
  }

  String get label {
    switch (this) {
      case ConsultationStatus.newRequest:
        return 'Новая';
      case ConsultationStatus.inProgress:
        return 'В работе';
      case ConsultationStatus.completed:
        return 'Завершена';
    }
  }
}

ConsultationStatus consultationStatusFromApi(String value) {
  switch (value) {
    case 'new':
      return ConsultationStatus.newRequest;
    case 'in_progress':
      return ConsultationStatus.inProgress;
    case 'completed':
      return ConsultationStatus.completed;
    default:
      return ConsultationStatus.newRequest;
  }
}

String consultationStatusToApi(ConsultationStatus status) => status.apiValue;
