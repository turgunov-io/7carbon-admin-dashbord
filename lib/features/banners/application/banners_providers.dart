import '../../../core/bloc/request_cubit.dart';
import '../data/banners_repository.dart';
import '../models/banner_item.dart';

class BannersCubit extends RequestCubit<List<BannerItem>> {
  BannersCubit(BannersRepository repository) : super(repository.fetchBanners);
}
