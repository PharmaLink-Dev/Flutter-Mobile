import '../entities/health_option.dart';
import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Profile> getProfile();
  Future<void> saveProfile(Profile profile);

  Future<List<HealthOption>> getAllergies();
  Future<List<HealthOption>> getConditions();
}

