class AppConstants {
  static const String baseUrl = 'https://urlmovil-1.onrender.com';
  static String? token;
  
  // 1. Rutas PÚBLICAS (SIN Interceptor / Sin Token)
  static const String login = '$baseUrl/api/auth/login';
  static const String register = '$baseUrl/api/auth/register';
  static const String forgotPassword = '$baseUrl/api/auth/forgot-password';
  static const String products = '$baseUrl/api/productos';
  static const String logout = '$baseUrl/api/auth/logout';
  static const String apiCategories = '$baseUrl/api/categorias';

  // 2. Rutas PRIVADAS (CON Interceptor / Necesitan Token)
  static const String verifyToken = '$baseUrl/api/auth/verify';
  static const String clients = '$baseUrl/api/clientes';
  static const String sales = '$baseUrl/api/ventas';
  static const String saleDetails = '$baseUrl/api/detalleventas';
  static const String returns = '$baseUrl/api/devoluciones';
  static const String changePassword = '$baseUrl/api/auth/change-password';
  
  // Constantes de Estado
  static const String statusPending = 'pendiente';
  static const String statusCompleted = 'completado';
}
