class Ingredient {
  final String name;
  final String status; // เช่น "เสี่ยงสูง", "ปลอดภัย"
  final String riskLevel; // เช่น "รุนแรง", "ปานกลาง"
  final String description; // รายละเอียดสำหรับ tab overview / interaction

  Ingredient({
    required this.name,
    required this.status,
    this.riskLevel = '',
    this.description = '',
  });
}
