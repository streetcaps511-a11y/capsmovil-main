import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';

// ==================== DETALLE DE VENTA ====================
class SaleDetailScreen extends StatefulWidget {
  final Map<String, dynamic> sale;

  const SaleDetailScreen({super.key, required this.sale});

  @override
  State<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends State<SaleDetailScreen> {
  bool _isLoading = false;

  // ✅ Función para mostrar el comprobante (Cloudinary + fallback)
  Widget _buildComprobanteImage(String? comprobantePath) {
    if (comprobantePath == null || comprobantePath.isEmpty) {
      return _buildPlaceholder();
    }

    // Si es ruta local vieja, ignórala (Render ya no la tiene)
    if (comprobantePath.startsWith('/uploads/')) {
      return _buildPlaceholder();
    }

    // Si es URL de Cloudinary, muéstrala
    if (comprobantePath.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          comprobantePath,
          fit: BoxFit.contain,
          width: double.infinity,
          height: 200,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              color: Colors.grey[850],
              child: const Center(
                child: CircularProgressIndicator(color: Colors.amber),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        ),
      );
    }

    // Por defecto, placeholder
    return _buildPlaceholder();
  }

  // ✅ Widget auxiliar para cuando no hay comprobante
  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, color: Colors.grey, size: 60),
          SizedBox(height: 12),
          Text(
            'Comprobante no disponible',
            style: TextStyle(color: Colors.grey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ✅ Formatear moneda
  String _formatCurrency(dynamic value) {
    if (value == null) return '\$0';
    final num = value is String ? double.tryParse(value) ?? 0 : value.toDouble();
    return '\$${num.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  // ✅ Actualizar estado de la venta
  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/api/ventas/${widget.sale['id']}/estado'),
        headers: {
          'Content-Type': 'application/json',
          if (AppConstants.token != null) 'Authorization': 'Bearer ${AppConstants.token}',
        },
        body: jsonEncode({'estado': newStatus}),
      );
      if (mounted && response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estado actualizado'), backgroundColor: Colors.green),
        );
        setState(() {
          widget.sale['estado'] = newStatus;
          widget.sale['statusenvio'] = newStatus;
        });
      } else {
        throw Exception('Error en la respuesta del servidor');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sale = widget.sale;
    final estadoStr = (sale['statusenvio'] ?? sale['estado'] ?? 'Completada').toString().toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Detalle de Venta', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.amber),
            onPressed: () {
              // Aquí podrías navegar a una pantalla de edición
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🏷️ ID y fecha
                  Card(
                    color: const Color(0xFF1E293B),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Venta #${sale['noVenta'] ?? sale['id']}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sale['createdAt']?.toString().substring(0, 10) ?? 'Fecha no disponible',
                                style: TextStyle(color: Colors.grey[400], fontSize: 13),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(estadoStr).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _getStatusColor(estadoStr), width: 1),
                            ),
                            child: Text(
                              estadoStr,
                              style: TextStyle(
                                color: _getStatusColor(estadoStr),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 👤 Cliente
                  _buildSectionTitle('Cliente'),
                  Card(
                    color: const Color(0xFF1E293B),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('Nombre', sale['clienteData']?['nombreCompleto'] ?? 'No disponible'),
                          _buildInfoRow('Teléfono', sale['clienteData']?['telefono'] ?? 'No disponible'),
                          _buildInfoRow('Dirección', sale['clienteData']?['direccion'] ?? 'No disponible'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 📦 Productos
                  _buildSectionTitle('Productos'),
                  Card(
                    color: const Color(0xFF1E293B),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (sale['detalles'] != null && sale['detalles'] is List)
                            ...List.generate(sale['detalles'].length, (index) {
                              final item = sale['detalles'][index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['producto']?['nombre'] ?? 'Producto sin nombre',
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            'Talla: ${item['talla'] ?? 'N/A'} | Cant: ${item['cantidad'] ?? 1}',
                                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      _formatCurrency(item['subtotal'] ?? item['precio'] ?? 0),
                                      style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          const Divider(color: Colors.white24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total:', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              Text(
                                _formatCurrency(sale['total'] ?? sale['monto'] ?? 0),
                                style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 🧾 Comprobante
                  _buildSectionTitle('Comprobante de Pago'),
                  _buildComprobanteImage(sale['comprobante']),
                  const SizedBox(height: 16),

                  // ⚙️ Acciones de estado (solo si es admin)
                  if (estadoStr != 'COMPLETADA' && estadoStr != 'CANCELADA') ...[
                    _buildSectionTitle('Actualizar Estado'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildStatusButton('Por Enviar', Colors.purple),
                        _buildStatusButton('Enviado', Colors.blue),
                        _buildStatusButton('Completada', Colors.green),
                        _buildStatusButton('Cancelada', Colors.red),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  // ✅ Helpers UI
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text('$label:', style: TextStyle(color: Colors.grey[400], fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildStatusButton(String label, Color color) {
    return ElevatedButton(
      onPressed: _isLoading ? null : () => _updateStatus(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'COMPLETADA':
      case 'APROBADA':
        return Colors.greenAccent;
      case 'ENVIADO':
        return Colors.blueAccent;
      case 'POR ENVIAR':
      case 'PENDIENTE':
        return Colors.amber;
      case 'CANCELADA':
      case 'RECHAZADA':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
}

// ==================== DETALLE DE DEVOLUCIÓN ====================
class ReturnDetailScreen extends StatelessWidget {
  final Map<String, dynamic> returnData;

  const ReturnDetailScreen({super.key, required this.returnData});

  @override
  Widget build(BuildContext context) {
    final ret = returnData;
    final estadoStr = (ret['estado'] ?? ret['status'] ?? 'Pendiente').toString().toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Detalle de Devolución', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🏷️ ID y estado
            Card(
              color: const Color(0xFF1E293B),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Devolución #${ret['id']}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ret['fecha']?.toString().substring(0, 10) ?? 'Fecha no disponible',
                          style: TextStyle(color: Colors.grey[400], fontSize: 13),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getReturnStatusColor(estadoStr).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _getReturnStatusColor(estadoStr), width: 1),
                      ),
                      child: Text(
                        estadoStr,
                        style: TextStyle(
                          color: _getReturnStatusColor(estadoStr),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 👤 Cliente
            _buildSectionTitle('Cliente'),
            Card(
              color: const Color(0xFF1E293B),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Nombre', ret['nombreCliente'] ?? 'No disponible'),
                    _buildInfoRow('Teléfono', ret['telefonoCliente'] ?? 'No disponible'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 📦 Productos
            _buildSectionTitle('Productos'),
            Card(
              color: const Color(0xFF1E293B),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Producto Original', ret['productoOriginal'] ?? 'No disponible'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Producto Cambio', ret['productoCambio'] ?? 'No aplica'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Motivo', ret['motivo'] ?? 'No especificado'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ✅ Helpers para Devolución
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text('$label:', style: TextStyle(color: Colors.grey[400], fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 14))),
        ],
      ),
    );
  }

  Color _getReturnStatusColor(String status) {
    switch (status) {
      case 'APROBADA':
      case 'COMPLETADA':
        return Colors.greenAccent;
      case 'RECHAZADA':
      case 'CANCELADA':
        return Colors.redAccent;
      default:
        return Colors.amber;
    }
  }
}