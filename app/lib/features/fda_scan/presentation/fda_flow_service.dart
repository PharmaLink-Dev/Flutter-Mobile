import 'package:flutter/material.dart';
import 'package:app/features/fda_scan/data/fda_search_service.dart';
import 'package:app/features/fda_scan/presentation/fda_not_found_screen.dart';
import 'package:app/features/fda_scan/presentation/fda_success_screen.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:app/features/history/data/fda_scan.dart';

/// Service to handle the flow of fetching FDA data and navigating to the correct result screen.
/// This centralizes the logic that was duplicated across multiple widgets.
class FdaFlowService {
  final BuildContext context;

  FdaFlowService(this.context);

  /// Fetches data for the given FDA number (or any string containing it)
  /// and navigates to either the success or not-found screen.
  Future<void> fetchAndNavigate(String fdaNumber) async {
    if (!context.mounted) return;

    // Show a loading indicator, if desired (optional)
    // showDialog(context: context, builder: (_) => Center(child: CircularProgressIndicator()));

    try {
      final service = FdaSearchService();
      final query = fdaNumber.replaceAll(RegExp(r'[^0-9]'), '');
      final map = await service.fetchByFdpdtno(query);

      if (!context.mounted) return;
      // if (Navigator.of(context).canPop()) Navigator.of(context).pop(); // Close loading dialog

      if (FdaSearchService.isValidResult(map)) {
        // --- IMPROVEMENT: Use product name for history entry ---
        final productName =
            map['ชื่อผลิตภัณฑ์(TH)']?.isNotEmpty ?? false ? map['ชื่อผลิตภัณฑ์(TH)'] : map['ชื่อผลิตภัณฑ์(EN)'];

        final box = Hive.box<FdaScan>('fda_scans');
        await box.add(
          FdaScan(
            id: const Uuid().v4(),
            fdaNumber: query,
            scanName: productName, // Use the fetched product name
            scanDate: DateTime.now(),
            fdaData: map,
          ),
        );
        Navigator.of(context).pushReplacement(
          // Use pushReplacement to avoid back button to a loading/intermediate state
          MaterialPageRoute(builder: (_) => FdaSuccessScreen(data: map)),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => FdaNotFoundScreen(scannedRaw: fdaNumber),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      // if (Navigator.of(context).canPop()) Navigator.of(context).pop(); // Close loading dialog
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => FdaNotFoundScreen(scannedRaw: fdaNumber),
        ),
      );
    }
  }
}
