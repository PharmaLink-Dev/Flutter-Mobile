import 'package:flutter/foundation.dart';
import '../../profile/domain/entities/health_option.dart';
import '../../profile/domain/entities/profile.dart';
import '../../profile/domain/usecases/get_allergies.dart';
import '../../profile/domain/usecases/get_conditions.dart';
import '../../profile/domain/usecases/get_profile.dart';
import '../../profile/domain/usecases/save_profile.dart';

class ProfileController extends ChangeNotifier {
  final GetProfile getProfileUsecase;
  final SaveProfile saveProfileUsecase;
  final GetAllergies getAllergiesUsecase;
  final GetConditions getConditionsUsecase;

  ProfileController({
    required this.getProfileUsecase,
    required this.saveProfileUsecase,
    required this.getAllergiesUsecase,
    required this.getConditionsUsecase,
  });

  // UI state
  bool loading = false;
  String name = '';
  String ageText = '';
  List<HealthOption> allergies = const [];
  List<HealthOption> conditions = const [];
  final Set<String> selectedAllergyIds = {};
  final Set<String> selectedConditionIds = {};

  Future<void> init() async {
    loading = true;
    notifyListeners();
    final profile = await getProfileUsecase();
    final alls = await getAllergiesUsecase();
    final conds = await getConditionsUsecase();
    name = profile.name;
    ageText = profile.age.toString();
    selectedAllergyIds
      ..clear()
      ..addAll(profile.allergyIds);
    selectedConditionIds
      ..clear()
      ..addAll(profile.conditionIds);
    allergies = alls;
    conditions = conds;
    loading = false;
    notifyListeners();
  }

  void toggleAllergy(String id) {
    if (selectedAllergyIds.contains(id)) {
      selectedAllergyIds.remove(id);
    } else {
      selectedAllergyIds.add(id);
    }
    notifyListeners();
  }

  void toggleCondition(String id) {
    if (selectedConditionIds.contains(id)) {
      selectedConditionIds.remove(id);
    } else {
      selectedConditionIds.add(id);
    }
    notifyListeners();
  }

  Future<void> save() async {
    final age = int.tryParse(ageText) ?? 0;
    final profile = Profile(
      name: name.trim(),
      age: age,
      allergyIds: selectedAllergyIds.toList(),
      conditionIds: selectedConditionIds.toList(),
    );
    loading = true;
    notifyListeners();
    await saveProfileUsecase(profile);
    loading = false;
    notifyListeners();
  }
}

