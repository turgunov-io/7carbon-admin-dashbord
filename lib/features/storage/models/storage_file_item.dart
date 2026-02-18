import 'package:json_annotation/json_annotation.dart';

part 'storage_file_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class StorageFileItem {
  const StorageFileItem({
    this.id,
    this.bucket,
    this.path,
    this.name,
    this.publicUrl,
    this.storageUrl,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? bucket;
  final String? path;
  final String? name;
  final String? publicUrl;
  final String? storageUrl;
  final String? createdAt;
  final String? updatedAt;

  factory StorageFileItem.fromJson(Map<String, dynamic> json) =>
      _$StorageFileItemFromJson(json);

  Map<String, dynamic> toJson() => _$StorageFileItemToJson(this);
}
