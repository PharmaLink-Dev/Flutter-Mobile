class Ingredient {
  final String name;
  final double? mg;
  final String status; // เช่น "เสี่ยงสูง", "ปลอดภัย"
  final String riskLevel; // เช่น "รุนแรง", "ปานกลาง"
  final String description; // รายละเอียดสำหรับ tab overview / interaction

  /// ชื่อที่ใช้ค้นหาใน Database (search_term จาก RPC)
  /// สำหรับใช้ในการ match กับ OCR name โดยไม่กระทบชื่อที่แสดงผล
  final String? searchTerm;

  Ingredient({
    required this.name,
    this.mg,
    required this.status,
    this.riskLevel = '',
    this.description = '',
    this.searchTerm,
  });

  Ingredient copyWith({
    String? name,
    double? mg,
    String? status,
    String? riskLevel,
    String? description,
    String? searchTerm,
  }) {
    return Ingredient(
      name: name ?? this.name,
      mg: mg ?? this.mg,
      status: status ?? this.status,
      riskLevel: riskLevel ?? this.riskLevel,
      description: description ?? this.description,
      searchTerm: searchTerm ?? this.searchTerm,
    );
  }
}
