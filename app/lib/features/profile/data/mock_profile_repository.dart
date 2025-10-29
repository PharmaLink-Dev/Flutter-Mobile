import '../domain/entities/health_option.dart';
import '../domain/entities/profile.dart';
import '../domain/repositories/profile_repository.dart';
import 'mock_data.dart';

class MockProfileRepository implements ProfileRepository {
  @override
  Future<List<HealthOption>> getAllergies() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return mockAllergies;
  }

  @override
  Future<List<HealthOption>> getConditions() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return mockConditions;
  }

  @override
  Future<Profile> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return mockCurrentProfile;
  }

  @override
  Future<void> saveProfile(Profile profile) async {
    await Future.delayed(const Duration(milliseconds: 150));
    saveMockProfile(profile);
  }
}

