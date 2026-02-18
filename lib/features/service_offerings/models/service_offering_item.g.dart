// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_offering_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceOfferingItem _$ServiceOfferingItemFromJson(Map<String, dynamic> json) =>
    ServiceOfferingItem(
      id: (json['id'] as num).toInt(),
      serviceType: json['service_type'] as String?,
      title: json['title'] as String?,
      detailedDescription: json['detailed_description'] as String?,
      galleryImages:
          (json['gallery_images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      priceText: json['price_text'] as String?,
      position: json['position'] == null
          ? 0
          : ServiceOfferingItem._intFromJson(json['position']),
      createdAt: ServiceOfferingItem._dateFromJson(json['created_at']),
      updatedAt: ServiceOfferingItem._dateFromJson(json['updated_at']),
    );

Map<String, dynamic> _$ServiceOfferingItemToJson(
  ServiceOfferingItem instance,
) => <String, dynamic>{
  'id': instance.id,
  'service_type': instance.serviceType,
  'title': instance.title,
  'detailed_description': instance.detailedDescription,
  'gallery_images': instance.galleryImages,
  'price_text': instance.priceText,
  'position': instance.position,
  'created_at': ServiceOfferingItem._dateToJson(instance.createdAt),
  'updated_at': ServiceOfferingItem._dateToJson(instance.updatedAt),
};
