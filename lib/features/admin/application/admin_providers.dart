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
    final preparedPayload = _prepareCreatePayload(payload);
    await _wrapSubmit(() async {
      await _repository.create(_entity, preparedPayload);
      await load();
    });
  }

  Future<void> update(dynamic id, Map<String, dynamic> payload) async {
    await _wrapSubmit(() async {
      await _repository.update(_entity, id, payload);
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

  Map<String, dynamic> _prepareCreatePayload(Map<String, dynamic> payload) {
    final prepared = Map<String, dynamic>.from(payload);

    if (_entity.key == 'banners') {
      final rawSection = prepared['section']?.toString().trim() ?? '';
      if (rawSection.isEmpty) {
        prepared['section'] = 'home';
      }

      final explicitPriority = _toPriority(prepared['priority']);
      prepared['priority'] = explicitPriority ?? _nextBannerPriority();
    }

    if (_entity.key == 'service_offerings') {
      final explicitPosition = _toPriority(prepared['position']);
      prepared['position'] = explicitPosition ?? _nextServiceOfferingPosition();
    }

    return prepared;
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
