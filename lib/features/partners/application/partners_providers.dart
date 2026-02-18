import '../../../core/bloc/request_cubit.dart';
import '../data/partners_repository.dart';
import '../models/partner_item.dart';

class PartnersCubit extends RequestCubit<List<PartnerItem>> {
  PartnersCubit(PartnersRepository repository)
    : super(repository.fetchPartners);
}
