import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrHomepage extends StatefulWidget {
  const OcrHomepage({super.key});

  @override
  _OcrHomepageState createState() => _OcrHomepageState();
}

class _OcrHomepageState extends State<OcrHomepage> {
  File? _image;
  String _scannedText = 'Scan results will appear here.';
  bool _isScanning = false;

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _scannedText = 'Scanning...';
        _isScanning = true;
      });
      _scanText(_image!);
    }
  }

  Future<void> _takePhoto() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _scannedText = 'Scanning...';
        _isScanning = true;
      });
      _scanText(_image!);
    }
  }

  Future<void> _scanText(File imageFile) async {
    final InputImage inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    final RecognizedText recognizedText = await textRecognizer.processImage(
      inputImage,
    );

    String text = '';
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        text += line.text;
        print(line.text); 
      }
    }

    setState(() {
      _scannedText = text.isNotEmpty ? text : 'No text found.';
      _isScanning = false;
    });

    textRecognizer.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OCR Scanner'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _image != null
                  ? Image.file(_image!, height: 300)
                  : const Text('Please select an image to scan.'),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed:
                    _isScanning
                        ? null
                        : () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return SafeArea(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      leading: const Icon(Icons.photo_library),
                                      title: const Text('Pick from Gallery'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _pickImageFromGallery();
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.camera_alt),
                                      title: const Text('Take Photo'),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _takePhoto();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                icon:
                    _isScanning
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Icon(Icons.document_scanner),
                label: Text(_isScanning ? 'Scanning...' : 'Scan Image'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Scanned Text:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_scannedText, textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
