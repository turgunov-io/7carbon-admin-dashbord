import '../../../core/bloc/request_cubit.dart';
import '../data/about_repository.dart';
import '../models/about_response.dart';

class AboutCubit extends RequestCubit<AboutResponse> {
  AboutCubit(AboutRepository repository) : super(repository.fetchAbout);
}
