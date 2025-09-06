import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class SaveProfile {
  final ProfileRepository repo;
  SaveProfile(this.repo);

  Future<void> call(Profile profile) => repo.saveProfile(profile);
}

