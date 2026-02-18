import '../../../core/bloc/request_cubit.dart';
import '../data/tuning_repository.dart';
import '../models/tuning_item.dart';

class TuningCubit extends RequestCubit<List<TuningItem>> {
  TuningCubit(TuningRepository repository) : super(repository.fetchTuning);
}
