import '../../../core/bloc/request_cubit.dart';
import '../data/contact_repository.dart';
import '../models/contact_item.dart';

class ContactCubit extends RequestCubit<List<ContactItem>> {
  ContactCubit(ContactRepository repository) : super(repository.fetchContacts);
}
