import '../../../core/bloc/request_cubit.dart';
import '../data/service_offerings_repository.dart';
import '../models/service_offering_item.dart';

class ServiceOfferingsCubit extends RequestCubit<List<ServiceOfferingItem>> {
  ServiceOfferingsCubit(ServiceOfferingsRepository repository)
    : super(repository.fetchServiceOfferings);
}
