import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_error.dart';
import '../data/admin_repository.dart';
import '../domain/admin_entity_definition.dart';
import '../domain/admin_entity_registry.dart';
import '../models/admin_entity_item.dart';
import 'admin_entity_state.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = ApiClient.createDio();
  ref.onDispose(() {
    dio.close(force: true);
  });
  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.watch(apiClientProvider));
});

final adminEntitiesProvider = Provider<List<AdminEntityDefinition>>((ref) {
  return adminEntities;
});

final adminEntityByKeyProvider = Provider.family<AdminEntityDefinition, String>(
  (ref, key) {
    final entity = adminEntityMap[key];
    if (entity == null) {
      throw StateError('Неизвестная сущность: $key');
    }
    return entity;
  },
);

final adminEntityControllerProvider = StateNotifierProvider.autoDispose
    .family<AdminEntityController, AdminEntityState, String>((ref, key) {
      final repository = ref.watch(adminRepositoryProvider);
      final entity = ref.watch(adminEntityByKeyProvider(key));
      return AdminEntityController(repository: repository, entity: entity)
        ..load();
    });

class AdminEntityController extends StateNotifier<AdminEntityState> {
  AdminEntityController({
    required AdminRepository repository,
    required AdminEntityDefinition entity,
  }) : _repository = repository,
       _entity = entity,
       super(const AdminEntityState.initial());

  final AdminRepository _repository;
  final AdminEntityDefinition _entity;

  Future<void> load() async {
    if (!mounted) {
      return;
    }
    state = state.copyWith(
      status: AdminLoadStatus.loading,
      clearErrorMessage: true,
    );

    try {
      final items = await _repository.fetchList(_entity);
      if (!mounted) {
        return;
      }
      state = state.copyWith(
        status: AdminLoadStatus.success,
        items: items,
        clearErrorMessage: true,
      );
    } on ApiError catch (error) {
      if (!mounted) {
        return;
      }
      state = state.copyWith(
        status: AdminLoadStatus.failure,
        errorMessage: error.message,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      state = state.copyWith(
        status: AdminLoadStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> create(Map<String, dynamic> payload) async {
    final preparedPayload = _preparePayload(payload, isCreate: true);
    await _wrapSubmit(() async {
      await _submitCreate(preparedPayload);
      await load();
    });
  }

  Future<void> update(dynamic id, Map<String, dynamic> payload) async {
    final preparedPayload = _preparePayload(payload);
    await _wrapSubmit(() async {
      await _submitUpdate(id, preparedPayload);
      await load();
    });
  }

  Future<void> remove(dynamic id) async {
    await _wrapSubmit(() async {
      await _repository.delete(_entity, id);
      if (!mounted) {
        return;
      }
      final items = state.items
          .where((item) => item.id.toString() != id.toString())
          .toList(growable: false);
      if (!mounted) {
        return;
      }
      state = state.copyWith(items: items, clearErrorMessage: true);
    });
  }

  Future<AdminEntityItem> fetchDetails(dynamic id) {
    return _repository.fetchDetails(_entity, id);
  }

  Future<void> _submitCreate(Map<String, dynamic> payload) async {
    if (_entity.key != 'tuning') {
      await _repository.create(_entity, payload);
      return;
    }
    await _submitTuningWithFallback(
      payload: payload,
      submit: (nextPayload) => _repository.create(_entity, nextPayload),
    );
  }

  Future<void> _submitUpdate(dynamic id, Map<String, dynamic> payload) async {
    if (_entity.key != 'tuning') {
      await _repository.update(_entity, id, payload);
      return;
    }
    await _submitTuningWithFallback(
      payload: payload,
      submit: (nextPayload) => _repository.update(_entity, id, nextPayload),
    );
  }

  Future<void> _submitTuningWithFallback({
    required Map<String, dynamic> payload,
    required Future<void> Function(Map<String, dynamic> payload) submit,
  }) async {
    ApiError? lastError;
    var sawTitleNotEditable = false;
    var sawCreateFailed = false;

    for (final attempt in _buildTuningSubmitPayloads(payload)) {
      try {
        await submit(attempt);
        return;
      } on ApiError catch (error) {
        lastError = error;
        if (_isTitleNotEditableError(error)) {
          sawTitleNotEditable = true;
        }
        if (_isCreateFailedError(error)) {
          sawCreateFailed = true;
        }
      }
    }

    if (sawTitleNotEditable && sawCreateFailed) {
      throw const ApiError(
        type: ApiErrorType.validation,
        statusCode: 422,
        message:
            'Сервер отклоняет поле title, но без него не создаёт запись. Это ошибка backend для /admin/tuning.',
      );
    }

    if (lastError != null) {
      throw lastError;
    }

    throw const ApiError(
      type: ApiErrorType.unknown,
      message: 'Не удалось отправить данные для тюнинга.',
    );
  }

  Future<void> _wrapSubmit(Future<void> Function() action) async {
    if (!mounted) {
      return;
    }
    state = state.copyWith(submitting: true, clearErrorMessage: true);
    try {
      await action();
    } on ApiError catch (error) {
      if (mounted) {
        state = state.copyWith(errorMessage: error.message);
      }
      rethrow;
    } catch (error) {
      if (mounted) {
        state = state.copyWith(errorMessage: error.toString());
      }
      rethrow;
    } finally {
      if (mounted) {
        state = state.copyWith(submitting: false);
      }
    }
  }

  Map<String, dynamic> _preparePayload(
    Map<String, dynamic> payload, {
    bool isCreate = false,
  }) {
    final prepared = Map<String, dynamic>.from(payload);

    if (_entity.key == 'work_post') {
      _normalizeWorkPostPayload(prepared);
    }
    if (_entity.key == 'tuning') {
      _normalizeTuningPayload(prepared);
    }

    if (_entity.key == 'banners' && isCreate) {
      final rawSection = prepared['section']?.toString().trim() ?? '';
      if (rawSection.isEmpty) {
        prepared['section'] = 'home';
      }

      final explicitPriority = _toPriority(prepared['priority']);
      prepared['priority'] = explicitPriority ?? _nextBannerPriority();
    }

    if (_entity.key == 'service_offerings' && isCreate) {
      final explicitPosition = _toPriority(prepared['position']);
      prepared['position'] = explicitPosition ?? _nextServiceOfferingPosition();
    }

    return prepared;
  }

  void _normalizeWorkPostPayload(Map<String, dynamic> payload) {
    dynamic pick(List<String> keys) {
      for (final key in keys) {
        if (!payload.containsKey(key)) {
          continue;
        }
        final value = payload[key];
        if (value == null) {
          continue;
        }
        if (value is String && value.trim().isEmpty) {
          continue;
        }
        return value;
      }
      return null;
    }

    final title = pick(const ['title_model', 'title']);
    final description = pick(const ['card_description', 'description']);
    final fullDescription = pick(const ['full_description', 'fullDescription']);
    final imageUrl = pick(const ['card_image_url', 'image_url', 'imageUrl']);
    final videoUrl = pick(const ['video_link', 'video_url', 'videoUrl']);
    final workList = pick(const ['work_list', 'performedWorks']);
    final gallery = pick(const [
      'full_image_url',
      'gallery_images',
      'galleryImages',
    ]);

    if (title != null) {
      payload['title_model'] = title;
    }
    if (description != null) {
      payload['card_description'] = description;
    }
    if (fullDescription != null) {
      payload['full_description'] = fullDescription;
    }
    if (imageUrl != null) {
      payload['card_image_url'] = imageUrl;
    }
    if (videoUrl != null) {
      payload['video_link'] = videoUrl;
    }
    if (workList != null) {
      final normalized = _normalizeMixedList(workList);
      payload['work_list'] = normalized;
    }
    if (gallery != null) {
      final normalized = _normalizeStringList(gallery);
      // Backend for work_post expects JSON string for this field, not a native array.
      payload['full_image_url'] = jsonEncode(normalized);
    }

    // Backend validates editable keys strictly for this entity.
    for (final key in const <String>[
      'title',
      'description',
      'fullDescription',
      'imageUrl',
      'videoUrl',
      'performedWorks',
      'gallery_images',
      'galleryImages',
      'image_url',
      'video_url',
    ]) {
      payload.remove(key);
    }
  }

  void _normalizeTuningPayload(Map<String, dynamic> payload) {
    dynamic pick(List<String> keys) {
      for (final key in keys) {
        if (!payload.containsKey(key)) {
          continue;
        }
        final value = payload[key];
        if (_isEmptyValue(value)) {
          continue;
        }
        return value;
      }
      return null;
    }

    final brand = pick(const ['brand']);
    final model = pick(const ['model']);
    final title = pick(const ['title', 'title_model', 'description']);
    final price = pick(const ['price']);
    final description = pick(const ['description', 'title', 'title_model']);
    final cardDescription = pick(const ['card_description']);
    final fullDescription = pick(const ['full_description', 'fullDescription']);
    final cardImageUrl = pick(const [
      'card_image_url',
      'image_url',
      'imageUrl',
    ]);
    final videoImageUrl = pick(const ['video_image_url']);
    final videoLink = pick(const ['video_link', 'video_url', 'videoUrl']);
    final gallery = pick(const [
      'full_image_url',
      'gallery_images',
      'galleryImages',
    ]);

    if (brand != null) {
      payload['brand'] = brand.toString().trim();
    }
    if (model != null) {
      payload['model'] = model.toString().trim();
    }
    if (title != null) {
      payload['title'] = title.toString().trim();
    }
    if (description != null) {
      payload['description'] = description.toString().trim();
    } else if (title != null && !payload.containsKey('description')) {
      payload['description'] = title.toString().trim();
    }
    if (price != null) {
      payload['price'] = price.toString().trim();
    }
    if (cardDescription != null) {
      payload['card_description'] = cardDescription.toString().trim();
    }
    if (fullDescription != null) {
      payload['full_description'] = fullDescription.toString().trim();
    }
    if (cardImageUrl != null) {
      payload['card_image_url'] = cardImageUrl.toString().trim();
    }
    if (videoImageUrl != null) {
      payload['video_image_url'] = videoImageUrl.toString().trim();
    }
    if (videoLink != null) {
      payload['video_link'] = videoLink.toString().trim();
    }
    if (gallery != null) {
      payload['full_image_url'] = _normalizeStringList(gallery);
    }

    const allowedKeys = <String>{
      'brand',
      'model',
      'title',
      'description',
      'price',
      'card_description',
      'full_description',
      'card_image_url',
      'full_image_url',
      'video_image_url',
      'video_link',
    };

    payload.removeWhere((key, value) {
      if (!allowedKeys.contains(key)) {
        return true;
      }
      if (value == null) {
        return true;
      }
      if (value is String) {
        return value.trim().isEmpty;
      }
      if (value is List) {
        return value.isEmpty;
      }
      return false;
    });
  }

  List<Map<String, dynamic>> _buildTuningSubmitPayloads(
    Map<String, dynamic> payload,
  ) {
    final signatures = <String>{};
    final result = <Map<String, dynamic>>[];

    void addVariant(Map<String, dynamic> source) {
      final signature = jsonEncode(source);
      if (signatures.add(signature)) {
        result.add(source);
      }
    }

    final base = Map<String, dynamic>.from(payload);
    final titleCandidate = _pickText([
      base['title'],
      base['description'],
      base['card_description'],
    ]);

    final withTitle = Map<String, dynamic>.from(base);
    if (titleCandidate != null) {
      withTitle['title'] = titleCandidate;
    }
    addVariant(withTitle);
    final withTitleNoDescription = Map<String, dynamic>.from(withTitle)
      ..remove('description');
    addVariant(withTitleNoDescription);

    final withoutTitle = Map<String, dynamic>.from(base)..remove('title');
    if (titleCandidate != null && _isEmptyValue(withoutTitle['description'])) {
      withoutTitle['description'] = titleCandidate;
    }
    addVariant(withoutTitle);

    final expanded = <Map<String, dynamic>>[];
    for (final variant in result) {
      for (final galleryVariant in _buildTuningGalleryVariants(variant)) {
        final signature = jsonEncode(galleryVariant);
        if (signatures.add(signature)) {
          expanded.add(galleryVariant);
        }
      }
    }

    return [...result, ...expanded];
  }

  List<Map<String, dynamic>> _buildTuningGalleryVariants(
    Map<String, dynamic> payload,
  ) {
    if (!payload.containsKey('full_image_url')) {
      return const <Map<String, dynamic>>[];
    }
    final gallery = payload['full_image_url'];
    final normalized = _normalizeStringList(gallery);
    if (normalized.isEmpty) {
      return const <Map<String, dynamic>>[];
    }

    return <Map<String, dynamic>>[
      Map<String, dynamic>.from(payload)..['full_image_url'] = normalized,
      Map<String, dynamic>.from(payload)
        ..['full_image_url'] = jsonEncode(normalized),
    ];
  }

  String? _pickText(List<dynamic> values) {
    for (final value in values) {
      if (value == null) {
        continue;
      }
      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return null;
  }

  bool _isTitleNotEditableError(ApiError error) {
    if (error.statusCode != 422) {
      return false;
    }
    final message = error.message.toLowerCase();
    return message.contains('title') && message.contains('not editable');
  }

  bool _isCreateFailedError(ApiError error) {
    if (error.statusCode != 500) {
      return false;
    }
    return error.message.toLowerCase().contains('failed to create record');
  }

  List<dynamic> _normalizeMixedList(dynamic value) {
    if (value is List) {
      return value
          .where((item) => !_isEmptyValue(item))
          .toList(growable: false);
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        return const <dynamic>[];
      }
      final decoded = _tryJsonDecode(trimmed);
      if (decoded is List) {
        return decoded
            .where((item) => !_isEmptyValue(item))
            .toList(growable: false);
      }
      return trimmed
          .split(RegExp(r'[\n,]'))
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }
    return _isEmptyValue(value) ? const <dynamic>[] : <dynamic>[value];
  }

  List<String> _normalizeStringList(dynamic value) {
    final result = <String>{};

    void collect(dynamic source) {
      if (source == null) {
        return;
      }
      if (source is List) {
        for (final item in source) {
          collect(item);
        }
        return;
      }
      if (source is String) {
        final trimmed = source.trim();
        if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') {
          return;
        }
        final decoded = _tryJsonDecode(trimmed);
        if (decoded is List) {
          collect(decoded);
          return;
        }
        if (trimmed.contains('\n') || trimmed.contains(',')) {
          for (final token in trimmed.split(RegExp(r'[\n,]'))) {
            collect(token);
          }
          return;
        }
        result.add(trimmed);
        return;
      }
      result.add(source.toString());
    }

    collect(value);
    return result.toList(growable: false);
  }

  dynamic _tryJsonDecode(String text) {
    try {
      return jsonDecode(text);
    } catch (_) {
      return null;
    }
  }

  bool _isEmptyValue(dynamic value) {
    if (value == null) {
      return true;
    }
    if (value is String) {
      return value.trim().isEmpty;
    }
    return false;
  }

  int _nextBannerPriority() {
    return _nextIntValueForField('priority');
  }

  int _nextServiceOfferingPosition() {
    return _nextIntValueForField('position');
  }

  int _nextIntValueForField(String fieldKey) {
    var maxValue = 0;
    for (final item in state.items) {
      final value = _toPriority(item.values[fieldKey]);
      if (value != null && value > maxValue) {
        maxValue = value;
      }
    }
    return maxValue + 1;
  }

  int? _toPriority(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }

    final raw = value.toString().trim();
    if (raw.isEmpty) {
      return null;
    }

    return int.tryParse(raw) ?? double.tryParse(raw)?.toInt();
  }
}
