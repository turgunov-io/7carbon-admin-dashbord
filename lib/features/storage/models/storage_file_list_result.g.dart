// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_file_list_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StorageFileListResult _$StorageFileListResultFromJson(
  Map<String, dynamic> json,
) => StorageFileListResult(
  files:
      (json['files'] as List<dynamic>?)
          ?.map((e) => StorageFileItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  meta: json['meta'] as Map<String, dynamic>? ?? {},
);

Map<String, dynamic> _$StorageFileListResultToJson(
  StorageFileListResult instance,
) => <String, dynamic>{'files': instance.files, 'meta': instance.meta};
