import '../entities/health_option.dart';
import '../repositories/profile_repository.dart';

class GetConditions {
  final ProfileRepository repo;
  GetConditions(this.repo);

  Future<List<HealthOption>> call() => repo.getConditions();
}

