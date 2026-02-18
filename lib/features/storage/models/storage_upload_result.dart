import 'package:json_annotation/json_annotation.dart';

part 'storage_upload_result.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class StorageUploadResult {
  const StorageUploadResult({
    required this.bucket,
    required this.path,
    required this.publicUrl,
    required this.storageUrl,
  });

  final String bucket;
  final String path;
  final String publicUrl;
  final String storageUrl;

  factory StorageUploadResult.fromJson(Map<String, dynamic> json) =>
      _$StorageUploadResultFromJson(json);

  Map<String, dynamic> toJson() => _$StorageUploadResultToJson(this);
}
