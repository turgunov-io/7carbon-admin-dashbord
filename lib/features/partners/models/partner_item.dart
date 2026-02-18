import 'package:json_annotation/json_annotation.dart';

part 'partner_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class PartnerItem {
  const PartnerItem({required this.id, required this.logoUrl});

  final int id;
  final String logoUrl;

  factory PartnerItem.fromJson(Map<String, dynamic> json) =>
      _$PartnerItemFromJson(json);

  Map<String, dynamic> toJson() => _$PartnerItemToJson(this);
}
