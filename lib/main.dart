import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart'; // Añadir esta importación
import 'core/routes/app_routes.dart';
import 'firebase_options.dart';
import 'presentation/admin_login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializar localización en español
  await initializeDateFormatting('es_ES', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SST Admin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'HelveticaRounded',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'HelveticaRounded'),
          bodyMedium: TextStyle(fontFamily: 'HelveticaRounded'),
          titleLarge: TextStyle(fontFamily: 'HelveticaRounded'),
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', 'ES')],
      locale: const Locale('es', 'ES'),
      initialRoute: AdminRoutes.login,
      routes: AdminRoutes.routes,
      home: const AdminLoginPage(),
    );
  }
}
