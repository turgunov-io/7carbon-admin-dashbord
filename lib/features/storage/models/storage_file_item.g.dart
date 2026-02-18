// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_file_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StorageFileItem _$StorageFileItemFromJson(Map<String, dynamic> json) =>
    StorageFileItem(
      id: json['id'] as String?,
      bucket: json['bucket'] as String?,
      path: json['path'] as String?,
      name: json['name'] as String?,
      publicUrl: json['public_url'] as String?,
      storageUrl: json['storage_url'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$StorageFileItemToJson(StorageFileItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bucket': instance.bucket,
      'path': instance.path,
      'name': instance.name,
      'public_url': instance.publicUrl,
      'storage_url': instance.storageUrl,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
