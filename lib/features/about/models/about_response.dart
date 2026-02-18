import 'package:json_annotation/json_annotation.dart';

part 'about_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AboutResponse {
  const AboutResponse({
    required this.page,
    this.metrics = const <AboutMetric>[],
    this.sections = const <AboutSection>[],
  });

  final AboutPage? page;
  final List<AboutMetric> metrics;
  final List<AboutSection> sections;

  factory AboutResponse.fromJson(Map<String, dynamic> json) =>
      _$AboutResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AboutResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AboutPage {
  const AboutPage({
    required this.id,
    this.title,
    this.bannerImageUrl,
    this.introDescription,
    this.missionDescription,
    this.videoUrl,
    this.missionImageUrl,
  });

  final int id;
  final String? title;
  final String? bannerImageUrl;
  final String? introDescription;
  final String? missionDescription;
  final String? videoUrl;
  final String? missionImageUrl;

  factory AboutPage.fromJson(Map<String, dynamic> json) =>
      _$AboutPageFromJson(json);

  Map<String, dynamic> toJson() => _$AboutPageToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AboutMetric {
  const AboutMetric({
    required this.id,
    required this.key,
    required this.value,
    required this.label,
    required this.position,
  });

  final int id;
  final String key;
  final Object? value;
  final String label;
  final int position;

  factory AboutMetric.fromJson(Map<String, dynamic> json) =>
      _$AboutMetricFromJson(json);

  Map<String, dynamic> toJson() => _$AboutMetricToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AboutSection {
  const AboutSection({
    required this.id,
    required this.key,
    required this.title,
    required this.description,
    required this.position,
  });

  final int id;
  final String key;
  final String title;
  final String description;
  final int position;

  factory AboutSection.fromJson(Map<String, dynamic> json) =>
      _$AboutSectionFromJson(json);

  Map<String, dynamic> toJson() => _$AboutSectionToJson(this);
}
