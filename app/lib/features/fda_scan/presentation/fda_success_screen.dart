import 'package:flutter/material.dart';
import 'package:app/shared/app_colors.dart';
import 'widgets/fda_result_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';

class FdaSuccessScreen extends StatelessWidget {
  final Map<String, String?> data;

  const FdaSuccessScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final successColor = appColors.primary;

    return Scaffold(
      backgroundColor: successColor, // A consistent background color
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.50,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [successColor.withValues(alpha: 0.8), successColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Decorative shapes using onPrimary color for contrast
                  Positioned(
                    top: 56,
                    left: 28,
                    child: _SoftShape.circle(
                      18,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  Positioned(
                    top: 96,
                    right: 36,
                    child: _SoftShape.rounded(
                      44,
                      14,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  Positioned(
                    bottom: 96,
                    left: 64,
                    child: _SoftShape.rounded(
                      56,
                      12,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  Positioned(
                    bottom: 120,
                    right: 40,
                    child: _SoftShape.circle(
                      12,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 60,
                    ), // Push content up
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Use onPrimary for the circle to contrast with the green background
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white, // White in light, dark in dark
                          ),
                          child: Center(
                            child: Icon(
                              Icons.check_circle_outline_rounded,
                              size: 72,
                              color: successColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'ผลิตภัณฑ์ขึ้นทะเบียน !',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors
                                .white, // Text color contrasts with background
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ข้อมูลตรวจสอบจากฐานข้อมูล\nสำนักงานคณะกรรมการอาหารและยา กระทรวงสาธารณสุข',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // The BottomSheet which is now theme-aware
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              bottom: false,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.56,
                child: FdaResultBottomSheet(data: data),
              ),
            ),
          ),

          // Back button, also using theme-aware colors
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                      colorScheme.onPrimary.withOpacity(0.2),
                    ),
                  ),
                  icon: Icon(CupertinoIcons.back, color: colorScheme.onPrimary),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftShape {
  static Widget circle(double size, {required Color color}) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  static Widget rounded(double width, double height, {required Color color}) =>
      Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      );
}
