import 'dart:typed_data';
import 'package:http/http.dart' as http;

class OcrUploader {
  final Uri endpoint;

  OcrUploader({
    Uri? endpoint,
  }) : endpoint = endpoint ?? Uri.parse('http://localhost:5678/webhook-test/pharmalink/ocr');

  Future<http.StreamedResponse> uploadImageBytes(Uint8List bytes, {String filename = 'image.jpg'}) async {
    final request = http.MultipartRequest('POST', endpoint);
    request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));

    return request.send();
  }
}
