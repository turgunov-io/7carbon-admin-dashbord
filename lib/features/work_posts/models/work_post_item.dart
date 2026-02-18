import 'package:json_annotation/json_annotation.dart';

part 'work_post_item.g.dart';

@JsonSerializable()
class WorkPostItem {
  const WorkPostItem({
    required this.id,
    required this.title,
    required this.description,
    required this.fullDescription,
    this.imageUrl,
    this.videoUrl,
    this.performedWorks = const <String>[],
    this.galleryImages = const <String>[],
  });

  final int id;
  final String title;
  final String description;
  final String fullDescription;
  final String? imageUrl;
  final String? videoUrl;
  final List<String> performedWorks;
  final List<String> galleryImages;

  factory WorkPostItem.fromJson(Map<String, dynamic> json) =>
      _$WorkPostItemFromJson(json);

  Map<String, dynamic> toJson() => _$WorkPostItemToJson(this);
}
