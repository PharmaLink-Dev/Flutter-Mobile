import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class GetProfile {
  final ProfileRepository repo;
  GetProfile(this.repo);

  Future<Profile> call() => repo.getProfile();
}

