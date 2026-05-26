import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import 'catalog_page.dart';
import 'auth_page.dart';
import 'admin_detail_screens.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = -1;

  final List<Key> _pageKeys = [
    UniqueKey(),
    UniqueKey(),
    const ValueKey('catalog'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      if (_selectedIndex != index) {
        if (index == 0 || index == 1) {
          _pageKeys[index] = UniqueKey();
        }
        _selectedIndex = index;
      }
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('¿Cerrar Sesión?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text('¿Estás seguro de que deseas cerrar sesión?', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  if (AppConstants.token != null) {
                    await http.post(
                      Uri.parse(AppConstants.logout),
                      headers: {
                        'Authorization': 'Bearer ${AppConstants.token}',
                        'Content-Type': 'application/json',
                      },
                      body: jsonEncode({'platform': 'app'}),
                    );
                  }
                } catch (e) {
                  debugPrint('Error al cerrar sesión en el servidor: $e');
                }
                AppConstants.token = null;
                if (context.mounted) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AuthPage()),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData selectedIcon, String label) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.amber.withValues(alpha: 0.7) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected ? Colors.amber : Colors.white60,
                size: 26,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.amber : Colors.white60,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, Icons.point_of_sale_outlined, Icons.point_of_sale, 'Ventas'),
          _buildNavItem(1, Icons.assignment_return_outlined, Icons.assignment_return, 'Devoluciones'),
          _buildNavItem(2, Icons.auto_awesome_mosaic_outlined, Icons.auto_awesome_mosaic, 'Catálogo'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Image.network(
          'https://res.cloudinary.com/dxc5qqsjd/image/upload/v1777323831/logo_hb4ota.png',
          height: 40,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(icon: const Icon(Icons.logout, color: Colors.amber), onPressed: _logout, tooltip: 'Cerrar sesión'),
          const SizedBox(width: 8),
        ],
      ),
      body: _selectedIndex == -1
          ? const AdminWelcomePage()
          : IndexedStack(
              index: _selectedIndex,
              children: [
                SigueVentasPage(key: _pageKeys[0]),
                DevolucionesPage(key: _pageKeys[1]),
                const CatalogPage(),
              ],
            ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }
}

// ==================== ADMIN WELCOME PAGE ====================
class AdminWelcomePage extends StatelessWidget {
  const AdminWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0.15,
            child: Image.network(
              'https://res.cloudinary.com/dxc5qqsjd/image/upload/v1764642176/WhatsApp_Image_2025-12-01_at_9.07.34_PM_a3k3ob.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.admin_panel_settings, size: 80, color: Colors.amber),
                  SizedBox(height: 24),
                  Text('Bienvenido,\nDuvan Stiven Mariaca Cartagena', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 12),
                  Text('Panel de administración', style: TextStyle(fontSize: 16, color: Colors.white70)),
                  SizedBox(height: 40),
                  Text('Selecciona una opción en el menú inferior\npara comenzar a gestionar.', textAlign: TextAlign.center, style: TextStyle(color: Colors.amber, height: 1.5, fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== SIGUE VENTAS PAGE ====================
class SigueVentasPage extends StatefulWidget {
  const SigueVentasPage({super.key});

  @override
  State<SigueVentasPage> createState() => _SigueVentasPageState();
}

class _SigueVentasPageState extends State<SigueVentasPage> {
  int _limit = 4;
  List<dynamic> allSales = [];
  bool isLoading = true;
  String errorMessage = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ✅ FUNCIÓN AGREGADA: formatCurrency
  String formatCurrency(dynamic value) {
    if (value == null) return '0';
    final num = value is String ? double.tryParse(value) ?? 0 : value.toDouble();
    return '\$${num.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }

  @override
  void initState() {
    super.initState();
    _fetchSales();
  }

  Future<void> _fetchSales() async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.sales),
        headers: {if (AppConstants.token != null) 'Authorization': 'Bearer ${AppConstants.token}'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          if (data['data'] != null && data['data'] is List) {
            allSales = data['data'];
          } else if (data is List) {
            allSales = data;
          }
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Error al cargar ventas (${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error de red. Intenta nuevamente.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator(color: Colors.amber));
    if (errorMessage.isNotEmpty) return Center(child: Text(errorMessage, style: const TextStyle(color: Colors.redAccent)));
    if (allSales.isEmpty) return const Center(child: Text('No hay ventas registradas', style: TextStyle(color: Colors.white70)));

    final filteredSales = allSales.where((sale) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final id = (sale['noVenta'] ?? sale['id'] ?? '').toString().toLowerCase();
      final total = formatCurrency(sale['total'] ?? sale['monto'] ?? 0).toLowerCase();
      String estadoStr = (sale['idEstado'] ?? sale['estado'] ?? 'Completada').toString().toLowerCase();
      if (estadoStr == 'completada' && sale['statusenvio'] != null) estadoStr = sale['statusenvio'].toString().toLowerCase();
      final client = (sale['clienteData'] != null ? sale['clienteData']['nombreCompleto'] ?? '' : '').toString().toLowerCase();
      String date = '';
      if (sale['createdAt'] != null) date = sale['createdAt'].toString().substring(0, 10);
      else if (sale['fecha'] != null) date = sale['fecha'].toString().substring(0, 10);
      date = date.toLowerCase();
      return id.contains(query) || total.contains(query) || estadoStr.contains(query) || client.contains(query) || date.contains(query);
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _isSearching
                  ? Row(
                      key: const ValueKey('searchBarVentas'),
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) => setState(() => _searchQuery = value),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Buscar venta...',
                              hintStyle: const TextStyle(color: Colors.white54),
                              prefixIcon: const Icon(Icons.search, color: Colors.amber),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear, color: Colors.white54),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              ),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.amber, width: 1)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.amber, width: 2)),
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(icon: const Icon(Icons.close, color: Colors.amber), onPressed: () => setState(() { _isSearching = false; _searchQuery = ''; _searchController.clear(); })),
                      ],
                    )
                  : Row(
                      key: const ValueKey('titleVentas'),
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Últimas Ventas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
                        IconButton(icon: const Icon(Icons.search, color: Colors.amber), onPressed: () => setState(() => _isSearching = true)),
                      ],
                    ),
            ),
          ),
        ),
        if (filteredSales.isEmpty && _searchQuery.isNotEmpty)
          const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.symmetric(vertical: 40.0), child: Center(child: Text('No se encontraron ventas para esta búsqueda', style: TextStyle(color: Colors.white54, fontSize: 16))))),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.75),
            delegate: SliverChildBuilderDelegate((context, index) {
              final sale = filteredSales[index];
              final id = sale['noVenta'] ?? sale['id'] ?? index;
              final total = formatCurrency(sale['total'] ?? sale['monto'] ?? 0);
              String date = '';
              if (sale['createdAt'] != null) date = sale['createdAt'].toString().substring(0, 10);
              else if (sale['fecha'] != null) date = sale['fecha'].toString().substring(0, 10);
              String estadoStr = (sale['idEstado'] ?? sale['estado'] ?? 'Completada').toString().toUpperCase();
              if (estadoStr == 'COMPLETADA' && sale['statusenvio'] != null) estadoStr = sale['statusenvio'].toString().toUpperCase();
              Color statusColor = Colors.greenAccent;
              if (estadoStr == 'RECHAZADA' || estadoStr == 'CANCELADA' || estadoStr == 'ANULADA') statusColor = Colors.redAccent;
              else if (estadoStr == 'PENDIENTE' || estadoStr == 'PAGO INCOMPLETO') statusColor = Colors.amber;
              else if (estadoStr == 'POR ENVIAR') statusColor = Colors.purpleAccent;
              else if (estadoStr == 'ENVIADO') statusColor = Colors.blueAccent;

              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SaleDetailScreen(sale: sale))),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.5), width: 1.0),
                    boxShadow: [BoxShadow(color: Colors.green.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_bag, size: 40, color: Colors.amber),
                      const SizedBox(height: 16),
                      Text('Venta #$id', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Text(date.isNotEmpty ? date : 'Reciente', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 16),
                      Text('\$$total', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(20), border: Border.all(color: statusColor.withValues(alpha: 0.5), width: 1.0)),
                        child: Text(estadoStr, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                ),
              );
            }, childCount: _limit > filteredSales.length ? filteredSales.length : _limit),
          ),
        ),
        if (_limit < filteredSales.length)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: OutlinedButton(
                  onPressed: () => setState(() => _limit += 4),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.amber, side: const BorderSide(color: Colors.amber), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
                  child: const Text('Ver más', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }
}

// ==================== DEVOLUCIONES PAGE ====================
class DevolucionesPage extends StatefulWidget {
  const DevolucionesPage({super.key});

  @override
  State<DevolucionesPage> createState() => _DevolucionesPageState();
}

class _DevolucionesPageState extends State<DevolucionesPage> {
  int _limit = 4;
  List<dynamic> allReturns = [];
  bool isLoading = true;
  String errorMessage = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchReturns();
  }

  Future<void> _fetchReturns() async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.returns),
        headers: {if (AppConstants.token != null) 'Authorization': 'Bearer ${AppConstants.token}'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          if (data['data'] != null && data['data'] is List) {
            allReturns = data['data'];
          } else if (data is List) {
            allReturns = data;
          }
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Error al cargar devoluciones (${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error de red. Intenta nuevamente.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator(color: Colors.amber));
    if (errorMessage.isNotEmpty) return Center(child: Text(errorMessage, style: const TextStyle(color: Colors.redAccent)));
    if (allReturns.isEmpty) return const Center(child: Text('No hay devoluciones registradas', style: TextStyle(color: Colors.white70)));

    final filteredReturns = allReturns.where((ret) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final id = (ret['id'] ?? '').toString().toLowerCase();
      final status = (ret['idEstado'] ?? ret['estado'] ?? ret['status'] ?? 'Pendiente').toString().toLowerCase();
      final client = (ret['nombreCliente'] ?? '').toString().toLowerCase();
      final prodOrig = (ret['productoOriginal'] ?? '').toString().toLowerCase();
      final prodCambio = (ret['productoCambio'] ?? '').toString().toLowerCase();
      final motivo = (ret['motivo'] ?? '').toString().toLowerCase();
      String fecha = '';
      if (ret['fecha'] != null) fecha = ret['fecha'].toString().substring(0, 10);
      fecha = fecha.toLowerCase();
      return id.contains(query) || status.contains(query) || client.contains(query) || prodOrig.contains(query) || prodCambio.contains(query) || motivo.contains(query) || fecha.contains(query);
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _isSearching
                  ? Row(
                      key: const ValueKey('searchBarDevoluciones'),
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) => setState(() => _searchQuery = value),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Buscar devolución...',
                              hintStyle: const TextStyle(color: Colors.white54),
                              prefixIcon: const Icon(Icons.search, color: Colors.amber),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear, color: Colors.white54),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              ),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.amber, width: 1)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.amber, width: 2)),
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(icon: const Icon(Icons.close, color: Colors.amber), onPressed: () => setState(() { _isSearching = false; _searchQuery = ''; _searchController.clear(); })),
                      ],
                    )
                  : Row(
                      key: const ValueKey('titleDevoluciones'),
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Últimas Devoluciones', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
                        IconButton(icon: const Icon(Icons.search, color: Colors.amber), onPressed: () => setState(() => _isSearching = true)),
                      ],
                    ),
            ),
          ),
        ),
        if (filteredReturns.isEmpty && _searchQuery.isNotEmpty)
          const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.symmetric(vertical: 40.0), child: Center(child: Text('No se encontraron devoluciones para esta búsqueda', style: TextStyle(color: Colors.white54, fontSize: 16))))),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.75),
            delegate: SliverChildBuilderDelegate((context, index) {
              final ret = filteredReturns[index];
              final id = ret['id'] ?? index;
              final estado = ret['idEstado'] ?? ret['estado'] ?? ret['status'] ?? 'Pendiente';
              final estadoStr = estado.toString().toUpperCase();
              Color statusColor = Colors.amber;
              if (estadoStr == 'COMPLETADA' || estadoStr == 'APROBADA') statusColor = Colors.greenAccent;
              else if (estadoStr == 'RECHAZADA' || estadoStr == 'CANCELADA') statusColor = Colors.redAccent;

              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReturnDetailScreen(returnData: ret))),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5), width: 1.0),
                    boxShadow: [BoxShadow(color: Colors.redAccent.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.assignment_return, size: 40, color: Colors.redAccent),
                      const SizedBox(height: 16),
                      Text('Devolución #$id', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(20), border: Border.all(color: statusColor.withValues(alpha: 0.5), width: 1.0)),
                        child: Text(estadoStr, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ],
                  ),
                ),
              );
            }, childCount: _limit > filteredReturns.length ? filteredReturns.length : _limit),
          ),
        ),
        if (_limit < filteredReturns.length)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: OutlinedButton(
                  onPressed: () => setState(() => _limit += 4),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.amber, side: const BorderSide(color: Colors.amber), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
                  child: const Text('Ver más', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }
}