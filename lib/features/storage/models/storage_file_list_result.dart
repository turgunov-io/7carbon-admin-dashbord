import 'package:json_annotation/json_annotation.dart';

import 'storage_file_item.dart';

part 'storage_file_list_result.g.dart';

@JsonSerializable()
class StorageFileListResult {
  const StorageFileListResult({
    required this.files,
    this.meta = const <String, dynamic>{},
  });

  @JsonKey(defaultValue: <StorageFileItem>[])
  final List<StorageFileItem> files;

  @JsonKey(defaultValue: <String, dynamic>{})
  final Map<String, dynamic> meta;

  factory StorageFileListResult.fromJson(Map<String, dynamic> json) =>
      _$StorageFileListResultFromJson(json);

  Map<String, dynamic> toJson() => _$StorageFileListResultToJson(this);
}
