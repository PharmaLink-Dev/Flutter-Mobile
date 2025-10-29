class Profile {
  final String name;
  final int age;
  final List<String> allergyIds;
  final List<String> conditionIds;

  const Profile({
    required this.name,
    required this.age,
    required this.allergyIds,
    required this.conditionIds,
  });

  Profile copyWith({
    String? name,
    int? age,
    List<String>? allergyIds,
    List<String>? conditionIds,
  }) {
    return Profile(
      name: name ?? this.name,
      age: age ?? this.age,
      allergyIds: allergyIds ?? this.allergyIds,
      conditionIds: conditionIds ?? this.conditionIds,
    );
  }
}

