
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app/features/home/widgets/quick_actions.dart';
import 'package:app/features/home/widgets/recent_scan_list.dart';
import 'package:app/features/home/widgets/searchBar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color kPrimaryColor = const Color(0xFF0C9869);
  final Color kBackgroundColor = const Color(0xFFF9F8FD);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      // สร้าง Custom App Bar ด้านบน
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ส่วนหัว + ช่องค้นหา
            HeaderWithSearchBox(
              size: size,
              primaryColor: kPrimaryColor,
            ),

            // ส่วน Quick Action (แทน Recommended เดิม)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: QuickActions(),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: RecentScanList(scanType: ScanType.ingredient),
            ),
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: kPrimaryColor,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            context.go('/settings');
          },
        ),
      ],
    );
  }
}

class HeaderWithSearchBox extends StatelessWidget {
  const HeaderWithSearchBox({
    super.key,
    required this.size,
    required this.primaryColor,
  });

  final Size size;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20 ),
      // ใช้ Stack เพื่อซ้อน Search bar ไว้กึ่งกลางรอยต่อ
      height: size.height * 0.18,
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 36 + 20,
            ),
            height: size.height * 0.18 - 27,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
            child: Row(
              children: <Widget>[
                Text(
                  'Welcome to kidness',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
              ],
            ),
          ),
          // Search Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: HomeSearchBar(primaryColor: primaryColor),
          ),
        ],
      ),
    );
  }
}
