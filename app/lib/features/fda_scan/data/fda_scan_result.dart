import 'dart:typed_data';

class FdaScanResult {
  final Uint8List? scanImage;
  final String fdaNumber;
  final String scanName;

  FdaScanResult({
    this.scanImage,
    required this.fdaNumber,
    String? scanName,
  }) : scanName = scanName ?? fdaNumber;
}
