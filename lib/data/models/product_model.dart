import '../../domain/entities/product.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    super.imageUrl,
    required super.categoryId,
    required super.stock,
    super.precioNormal = 0.0,
    super.precioDescuento = 0.0,
    super.precioMayorista6 = 0.0,
    super.precioMayorista80 = 0.0,
    super.enOfertaVenta = false,
    super.porcentajeDescuento,
    super.tallasStock = const [],
    super.colores = const [],
    super.imagenes = const [],
    super.categoriaNombre = '',
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Manejo de diferentes formatos de precio que vienen de la API
    final priceStr = json['precioVenta'] ?? json['precio_normal'] ?? '0.00';
    final imageUrlsRaw = json['imagenes'] as List?;
    final List<String> imageUrls = imageUrlsRaw?.map((e) => e.toString()).toList() ?? [];
    
    return ProductModel(
      id: json['id'] ?? json['id_producto'],
      name: json['nombre'] ?? '',
      description: json['descripcion'] ?? '',
      price: double.tryParse(priceStr.toString()) ?? 0.0,
      imageUrl: imageUrls.isNotEmpty ? imageUrls[0] : null,
      categoryId: json['idCategoria'] ?? 0,
      stock: json['stock'] ?? 0,
      precioNormal: double.tryParse((json['precio_normal'] ?? json['precioVenta'] ?? '0').toString()) ?? 0.0,
      precioDescuento: double.tryParse((json['precio_descuento'] ?? json['precioOferta'] ?? '0').toString()) ?? 0.0,
      precioMayorista6: double.tryParse((json['precio_mayorista6'] ?? json['precioMayorista6'] ?? '0').toString()) ?? 0.0,
      precioMayorista80: double.tryParse((json['precio_mayorista80'] ?? json['precioMayorista80'] ?? '0').toString()) ?? 0.0,
      enOfertaVenta: json['enOfertaVenta'] ?? json['is_oferta'] ?? false,
      porcentajeDescuento: json['porcentajeDescuento'],
      tallasStock: json['tallasStock'] ?? [],
      colores: (json['colores'] as List?)?.map((e) => e.toString()).toList() ?? [],
      imagenes: imageUrls,
      categoriaNombre: json['categoria_nombre'] ?? json['categoria'] ?? '',
    );
  }
}
