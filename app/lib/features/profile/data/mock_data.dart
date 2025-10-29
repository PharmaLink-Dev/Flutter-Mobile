import '../../profile/domain/entities/health_option.dart';
import '../../profile/domain/entities/profile.dart';

/// Simple in-memory mock store
class _MockStore {
  static Profile profile = const Profile(
    name: 'Sarah',
    age: 28,
    allergyIds: ['tree_nuts'],
    conditionIds: ['diabetes'],
  );

  static const List<HealthOption> allergies = [
    HealthOption(id: 'tree_nuts', name: 'Tree Nuts', emoji: '🥜'),
    HealthOption(id: 'dairy', name: 'Dairy Products', emoji: '🥛'),
    HealthOption(id: 'gluten', name: 'Gluten', emoji: '🌾'),
    HealthOption(id: 'shellfish', name: 'Shellfish', emoji: '🦐'),
    HealthOption(id: 'eggs', name: 'Eggs', emoji: '🥚'),
    HealthOption(id: 'soy', name: 'Soy', emoji: '🫘'),
  ];

  static const List<HealthOption> conditions = [
    HealthOption(id: 'diabetes', name: 'Diabetes', emoji: '🩸'),
    HealthOption(id: 'hypertension', name: 'High Blood Pressure', emoji: '💗'),
    HealthOption(id: 'kidney', name: 'Kidney Disease', emoji: '🧫'),
    HealthOption(id: 'liver', name: 'Liver Disease', emoji: '🫀'),
    HealthOption(id: 'thyroid', name: 'Thyroid Issues', emoji: '🦋'),
    HealthOption(id: 'arthritis', name: 'Arthritis', emoji: '🦴'),
  ];
}

Profile get mockCurrentProfile => _MockStore.profile;
List<HealthOption> get mockAllergies => _MockStore.allergies;
List<HealthOption> get mockConditions => _MockStore.conditions;

void saveMockProfile(Profile p) {
  _MockStore.profile = p;
}
