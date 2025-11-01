import 'package:app/features/history/data/fda_scan.dart';
import 'package:app/features/history/data/ingredient.dart';
import 'package:app/features/history/data/scan_history.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register all adapters
  Hive.registerAdapter(IngredientAdapter()); // typeId: 1
  Hive.registerAdapter(ScanHistoryAdapter()); // typeId: 0
  Hive.registerAdapter(FdaScanAdapter()); // typeId: 2

  // Open the boxes
  await Hive.openBox<Ingredient>('ingredients'); // Good practice to have a box for them
  await Hive.openBox<ScanHistory>('history');
  await Hive.openBox<FdaScan>('fda_scans');


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      title: 'PharmaLink',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
    );
  }
}
