// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PortfolioItem _$PortfolioItemFromJson(Map<String, dynamic> json) =>
    PortfolioItem(
      id: (json['id'] as num).toInt(),
      brand: json['brand'] as String?,
      title: json['title'] as String,
      imageUrl: json['image_url'] as String,
      description: json['description'] as String?,
      youtubeLink: json['youtube_link'] as String?,
      createdAt: PortfolioItem._dateFromJson(json['created_at']),
    );

Map<String, dynamic> _$PortfolioItemToJson(PortfolioItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'brand': instance.brand,
      'title': instance.title,
      'image_url': instance.imageUrl,
      'description': instance.description,
      'youtube_link': instance.youtubeLink,
      'created_at': PortfolioItem._dateToJson(instance.createdAt),
    };
