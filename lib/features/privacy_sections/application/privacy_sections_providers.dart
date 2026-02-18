import '../../../core/bloc/request_cubit.dart';
import '../data/privacy_sections_repository.dart';
import '../models/privacy_section_item.dart';

class PrivacySectionsCubit extends RequestCubit<List<PrivacySectionItem>> {
  PrivacySectionsCubit(PrivacySectionsRepository repository)
    : super(repository.fetchPrivacySections);
}
