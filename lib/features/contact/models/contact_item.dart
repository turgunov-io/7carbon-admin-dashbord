import 'package:json_annotation/json_annotation.dart';

part 'contact_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ContactItem {
  const ContactItem({
    required this.id,
    this.phoneNumber,
    this.address,
    this.description,
    this.email,
    this.workSchedule,
  });

  final int id;
  final String? phoneNumber;
  final String? address;
  final String? description;
  final String? email;
  final String? workSchedule;

  factory ContactItem.fromJson(Map<String, dynamic> json) =>
      _$ContactItemFromJson(json);

  Map<String, dynamic> toJson() => _$ContactItemToJson(this);
}
