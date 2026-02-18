// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_upload_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StorageUploadResult _$StorageUploadResultFromJson(Map<String, dynamic> json) =>
    StorageUploadResult(
      bucket: json['bucket'] as String,
      path: json['path'] as String,
      publicUrl: json['public_url'] as String,
      storageUrl: json['storage_url'] as String,
    );

Map<String, dynamic> _$StorageUploadResultToJson(
  StorageUploadResult instance,
) => <String, dynamic>{
  'bucket': instance.bucket,
  'path': instance.path,
  'public_url': instance.publicUrl,
  'storage_url': instance.storageUrl,
};
