import 'package:app/features/ingredient/presentation/confirmation_page.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode'), centerTitle: true),
      body: Stack(
        children: [
          // พื้นหลังกล้อง (ตอนนี้ยังเป็นสีดำแทนกล้อง)
          Container(
            color: Colors.black, //จะสามารถเปลี่ยนเป็นกล้องได้ตรงนี้ในอนาคต
            child: const Center(
              child: Text(
                'Camera Preview Placeholder',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ),

          // กรอบเล็งตรงกลาง (overlay)
          Center(
            child: DottedBorder(
              borderType: BorderType.Rect,
              color: Colors.white,
              strokeWidth: 3,
              dashPattern: const [8, 4], // ความยาวเส้น/ช่องว่าง
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
          ),

          // ปุ่มแฟลช
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.flash_on, color: Colors.white, size: 30),
              onPressed: null, // function เปิด-ปิดแฟลช (demo → ยังไม่ทำงาน)
            ),
          ),

          // ปุ่มสลับกล้อง
          Positioned(
            top: 80,
            right: 20,
            child: IconButton(
              icon: const Icon(
                Icons.cameraswitch,
                color: Colors.white,
                size: 30,
              ),
              onPressed:
                  null, // function สลับกล้องหน้า-หลัง (demo → ยังไม่ทำงาน)
            ),
          ),

          // ปุ่มถ่ายรูปตรงล่าง
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white, // สีขอบ
                    width: 2, // ความหนาของขอบ
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConfirmationPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                    backgroundColor: Colors.white24,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
