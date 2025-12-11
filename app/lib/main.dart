
import 'package:app/features/history/data/fda_scan.dart';
import 'package:app/features/history/data/history_ingredient.dart';
import 'package:app/features/history/data/scan_history.dart';
import 'package:app/features/settings/application/theme_provider.dart';
import 'package:app/service/supabase_init.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init();

  await Hive.initFlutter();
  Hive.registerAdapter(HistoryIngredientAdapter()); // typeId: 1
  Hive.registerAdapter(ScanHistoryAdapter()); // typeId: 0
  Hive.registerAdapter(FdaScanAdapter()); // typeId: 2

  // Open the boxes
  await Hive.openBox<HistoryIngredient>(
    'ingredients',
  ); // Good practice to have a box for them
  await Hive.openBox<ScanHistory>('history');
  await Hive.openBox<FdaScan>('fda_scans');

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      title: 'PharmaLink',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.green,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.green,
      ),
      themeMode: themeProvider.themeMode,
    );
  }
}
