import 'package:flutter/material.dart';
import 'package:app/shared/app_colors.dart';

/// SearchBarWidget
/// ----------------
/// SearchBar มุมมน + ปุ่ม search ด้านขวา
/// ใช้สีเขียวอ่อนจาก AppColors
class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  void _onSearchPressed(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Search feature coming soon..."),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // ✅ มุมมนแบบสี่เหลี่ยม
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // ช่องกรอกข้อความ
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: "Search...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          // ปุ่ม search
          InkWell(
            onTap: () => _onSearchPressed(context),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: const Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
