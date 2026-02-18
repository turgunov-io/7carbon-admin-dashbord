import '../../features/about/data/about_repository.dart';
import '../../features/banners/data/banners_repository.dart';
import '../../features/consultations/data/consultations_repository.dart';
import '../../features/contact/data/contact_repository.dart';
import '../../features/dashboard/data/dashboard_repository.dart';
import '../../features/partners/data/partners_repository.dart';
import '../../features/portfolio_items/data/portfolio_items_repository.dart';
import '../../features/privacy_sections/data/privacy_sections_repository.dart';
import '../../features/service_offerings/data/service_offerings_repository.dart';
import '../../features/tuning/data/tuning_repository.dart';
import '../../features/work_posts/data/work_posts_repository.dart';
import '../network/api_client.dart';

class AppDependencies {
  AppDependencies._({
    required this.apiClient,
    required this.dashboardRepository,
    required this.bannersRepository,
    required this.contactRepository,
    required this.aboutRepository,
    required this.partnersRepository,
    required this.tuningRepository,
    required this.serviceOfferingsRepository,
    required this.privacySectionsRepository,
    required this.portfolioItemsRepository,
    required this.workPostsRepository,
    required this.consultationsRepository,
  });

  final ApiClient apiClient;

  final DashboardRepository dashboardRepository;
  final BannersRepository bannersRepository;
  final ContactRepository contactRepository;
  final AboutRepository aboutRepository;
  final PartnersRepository partnersRepository;
  final TuningRepository tuningRepository;
  final ServiceOfferingsRepository serviceOfferingsRepository;
  final PrivacySectionsRepository privacySectionsRepository;
  final PortfolioItemsRepository portfolioItemsRepository;
  final WorkPostsRepository workPostsRepository;
  final ConsultationsRepository consultationsRepository;

  factory AppDependencies.create() {
    final apiClient = ApiClient.create();

    return AppDependencies._(
      apiClient: apiClient,
      dashboardRepository: DashboardRepository(apiClient),
      bannersRepository: BannersRepository(apiClient),
      contactRepository: ContactRepository(apiClient),
      aboutRepository: AboutRepository(apiClient),
      partnersRepository: PartnersRepository(apiClient),
      tuningRepository: TuningRepository(apiClient),
      serviceOfferingsRepository: ServiceOfferingsRepository(apiClient),
      privacySectionsRepository: PrivacySectionsRepository(apiClient),
      portfolioItemsRepository: PortfolioItemsRepository(apiClient),
      workPostsRepository: WorkPostsRepository(apiClient),
      consultationsRepository: ConsultationsRepository(apiClient),
    );
  }

  void dispose() {
    apiClient.dispose();
  }
}
