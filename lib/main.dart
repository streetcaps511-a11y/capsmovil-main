import 'package:flutter/material.dart';
import 'injection_container.dart' as di;
import 'core/themes/app_theme.dart';
import 'presentation/pages/auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  // 🔇 FILTRO GLOBAL: Silencia errores de imágenes rotas (Pinterest, etc.)
  FlutterError.onError = (FlutterErrorDetails details) {
    final error = details.exception.toString();
    
    // Ignora errores de carga de imágenes de red (Pinterest, URLs rotas, etc.)
    if (error.contains('NetworkImageLoadException') || 
        error.contains('i.pinimg.com') ||
        error.contains('HTTP request failed, statusCode: 0') ||
        error.contains('ImageResourceService')) {
      return; // No imprimas este error en la consola
    }
    
    // Para otros errores, sí imprímelos para poder depurar
    FlutterError.dumpErrorToConsole(details);
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caps Movil',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const AuthPage(),
    );
  }
}