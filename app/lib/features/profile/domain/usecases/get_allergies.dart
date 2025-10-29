import '../entities/health_option.dart';
import '../repositories/profile_repository.dart';

class GetAllergies {
  final ProfileRepository repo;
  GetAllergies(this.repo);

  Future<List<HealthOption>> call() => repo.getAllergies();
}

