import '../../../core/bloc/request_cubit.dart';
import '../data/dashboard_repository.dart';
import '../domain/dashboard_stats.dart';

class DashboardCubit extends RequestCubit<DashboardStats> {
  DashboardCubit(DashboardRepository repository) : super(repository.fetchStats);
}
