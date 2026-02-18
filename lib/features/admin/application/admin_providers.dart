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
    state = state.copyWith(
      status: AdminLoadStatus.loading,
      clearErrorMessage: true,
    );

    try {
      final items = await _repository.fetchList(_entity);
      state = state.copyWith(
        status: AdminLoadStatus.success,
        items: items,
        clearErrorMessage: true,
      );
    } on ApiError catch (error) {
      state = state.copyWith(
        status: AdminLoadStatus.failure,
        errorMessage: error.message,
      );
    } catch (error) {
      state = state.copyWith(
        status: AdminLoadStatus.failure,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> create(Map<String, dynamic> payload) async {
    await _wrapSubmit(() async {
      await _repository.create(_entity, payload);
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
      final items = state.items
          .where((item) => item.id.toString() != id.toString())
          .toList(growable: false);
      state = state.copyWith(items: items, clearErrorMessage: true);
    });
  }

  Future<AdminEntityItem> fetchDetails(dynamic id) {
    return _repository.fetchDetails(_entity, id);
  }

  Future<void> _wrapSubmit(Future<void> Function() action) async {
    state = state.copyWith(submitting: true, clearErrorMessage: true);
    try {
      await action();
    } on ApiError catch (error) {
      state = state.copyWith(errorMessage: error.message);
      rethrow;
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
      rethrow;
    } finally {
      state = state.copyWith(submitting: false);
    }
  }
}
