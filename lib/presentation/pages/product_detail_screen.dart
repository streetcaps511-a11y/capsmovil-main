import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../../core/constants/app_constants.dart';

String _getImageUrl(String path) {
  if (path == 'null' || path.trim().isEmpty) return '';
  if (path.startsWith('http')) return path;
  final cleanPath = path.startsWith('/') ? path : '/$path';
  return '${AppConstants.baseUrl}$cleanPath';
}

void _showFullScreenGallery(BuildContext context, List<String> imageUrls, {int initialIndex = 0, required String tagPrefix}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => FullScreenGallery(
        imageUrls: imageUrls,
        initialIndex: initialIndex,
        tagPrefix: tagPrefix,
      ),
    ),
  );
}

class FullScreenGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String tagPrefix;

  const FullScreenGallery({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    required this.tagPrefix,
  });

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final url = _getImageUrl(widget.imageUrls[index]);
              return Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 5.0,
                  child: Hero(
                    tag: '${widget.tagPrefix}_$index',
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator(color: Colors.amber));
                      },
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.broken_image, color: Colors.white54, size: 100),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  if (widget.imageUrls.length > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentIndex + 1} / ${widget.imageUrls.length}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductDetailScreen extends StatefulWidget {
  final ProductEntity product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String formatCurrency(dynamic value) {
    if (value == null) return '0';
    String numStr = value.toString();
    if (numStr.endsWith('.0')) numStr = numStr.substring(0, numStr.length - 2);
    if (numStr.endsWith('.00')) numStr = numStr.substring(0, numStr.length - 3);
    return numStr.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase().trim()) {
      case 'blanco': return Colors.white;
      case 'negro': return Colors.black;
      case 'rojo': return Colors.red;
      case 'azul': return Colors.blue;
      case 'verde': return Colors.green;
      case 'amarillo': return Colors.yellow;
      case 'gris': return Colors.grey;
      case 'beige': return const Color(0xFFF5F5DC);
      case 'rosado': return Colors.pink;
      case 'naranja': return Colors.orange;
      case 'morado': return Colors.purple;
      case 'cafe':
      case 'café':
      case 'marrón': return Colors.brown;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final priceNormal = formatCurrency(p.precioNormal > 0 ? p.precioNormal : p.price);
    final priceOferta = formatCurrency(p.precioDescuento > 0 ? p.precioDescuento : p.price);
    final priceMay6 = formatCurrency(p.precioMayorista6);
    final priceMay80 = formatCurrency(p.precioMayorista80);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber, width: 1.5),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back, color: Colors.amber),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Detalle del Producto', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Información detallada de "${p.name}"', style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información General
            _buildSection(
              title: 'Información General',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Nombre:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 4),
                            _buildFieldBox(p.name),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Categoría:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 4),
                            _buildFieldBox(p.categoriaNombre.isNotEmpty ? p.categoriaNombre : 'N/A'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Descripción:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  _buildFieldBox(p.description.isNotEmpty ? p.description : 'Sin descripción'),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Precios
            _buildSection(
              title: 'Precios',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Venta (Normal):', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 4),
                            _buildFieldBox('\$ $priceNormal'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Precio Oferta:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(child: _buildFieldBox('\$ $priceOferta')),
                                const SizedBox(width: 8),
                                Column(
                                  children: [
                                    Transform.scale(
                                      scale: 0.7,
                                      child: Switch(
                                        value: p.enOfertaVenta,
                                        onChanged: (val) {}, // Dummy function para que no se vea deshabilitado
                                        activeColor: Colors.amber,
                                        activeTrackColor: Colors.amber.withOpacity(0.4),
                                        inactiveThumbColor: Colors.grey,
                                        inactiveTrackColor: Colors.grey.withOpacity(0.3),
                                      ),
                                    ),
                                    const Text('OFERTA', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  if (p.porcentajeDescuento != null && p.porcentajeDescuento! > 0) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      alignment: Alignment.center,
                      child: Text('El descuento total es de ${p.porcentajeDescuento}%', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('+6 Unidades:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 4),
                            _buildFieldBox('\$ $priceMay6'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('+80 Unidades:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 4),
                            _buildFieldBox('\$ $priceMay80'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Tallas y Colores (Row on mobile if possible, otherwise Column)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _buildSection(
                    title: 'Tallas y Stock',
                    child: p.tallasStock.isEmpty 
                      ? const Text('Sin tallas registradas', style: TextStyle(color: Colors.white54))
                      : Column(
                          children: p.tallasStock.map((t) {
                            final tallaName = (t is Map) ? t['talla']?.toString() ?? 'N/A' : t.toString();
                            final qty = (t is Map) ? t['cantidad']?.toString() ?? '0' : '0';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Expanded(child: _buildFieldBox(tallaName)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1E293B),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.white10),
                                      ),
                                      child: Text('$qty uds', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: _buildSection(
                    title: 'Colores',
                    child: p.colores.isEmpty
                      ? const Text('N/A', style: TextStyle(color: Colors.white54))
                      : Column(
                          children: p.colores.map((c) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: _getColorFromName(c),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white30),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        c,
                                        style: const TextStyle(color: Colors.white, fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Imágenes del Producto
            _buildSection(
              title: 'Imágenes del Producto',
              child: p.imagenes.isEmpty
                ? const Text('No hay imágenes', style: TextStyle(color: Colors.white54))
                : Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Desliza para ver más', style: TextStyle(color: Colors.white38, fontSize: 11)),
                          if (p.imagenes.length > 1)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_currentPage + 1} / ${p.imagenes.length}',
                                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 300,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: p.imagenes.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                final url = _getImageUrl(p.imagenes[index]);
                                final heroTag = 'product_img_$index';
                                return GestureDetector(
                                  onTap: () => _showFullScreenGallery(
                                    context,
                                    p.imagenes,
                                    initialIndex: index,
                                    tagPrefix: 'product_img',
                                  ),
                                  child: Hero(
                                    tag: 'product_img_$index',
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1E293B),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white10),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          url,
                                          fit: BoxFit.contain,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return const Center(child: CircularProgressIndicator(color: Colors.amber));
                                          },
                                          errorBuilder: (context, error, stackTrace) => const Center(
                                            child: Icon(Icons.broken_image, color: Colors.white24, size: 50),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (p.imagenes.length > 1) ...[
                            if (_currentPage > 0)
                              Positioned(
                                left: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.amber, size: 28),
                                  onPressed: () {
                                    _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                                  },
                                ),
                              ),
                            if (_currentPage < p.imagenes.length - 1)
                              Positioned(
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.amber, size: 28),
                                  onPressed: () {
                                    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                                  },
                                ),
                              ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Center(
                        child: Text(
                          'Toca la imagen para ampliar',
                          style: TextStyle(color: Colors.white54, fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildFieldBox(String text, {Color color = Colors.white, double fontSize = 13}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: fontSize),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    );
  }
}
