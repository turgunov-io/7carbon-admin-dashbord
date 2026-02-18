import 'package:intl/intl.dart';

const dashValue = '\u2014';

String textOrDash(String? value) {
  if (value == null) {
    return dashValue;
  }
  final normalized = value.trim();
  return normalized.isEmpty ? dashValue : normalized;
}

String objectOrDash(Object? value) {
  if (value == null) {
    return dashValue;
  }
  final stringValue = value.toString().trim();
  return stringValue.isEmpty ? dashValue : stringValue;
}

String formatDateTimeOrDash(DateTime? value) {
  if (value == null) {
    return dashValue;
  }
  return DateFormat('yyyy-MM-dd HH:mm').format(value.toLocal());
}
