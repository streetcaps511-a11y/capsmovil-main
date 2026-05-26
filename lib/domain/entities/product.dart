import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final int categoryId;
  final int stock;
  
  final double precioNormal;
  final double precioDescuento;
  final double precioMayorista6;
  final double precioMayorista80;
  final bool enOfertaVenta;
  final int? porcentajeDescuento;
  final List<dynamic> tallasStock;
  final List<String> colores;
  final List<String> imagenes;
  final String categoriaNombre;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.categoryId,
    required this.stock,
    this.precioNormal = 0.0,
    this.precioDescuento = 0.0,
    this.precioMayorista6 = 0.0,
    this.precioMayorista80 = 0.0,
    this.enOfertaVenta = false,
    this.porcentajeDescuento,
    this.tallasStock = const [],
    this.colores = const [],
    this.imagenes = const [],
    this.categoriaNombre = '',
  });

  @override
  List<Object?> get props => [
    id, name, description, price, imageUrl, categoryId, stock,
    precioNormal, precioDescuento, precioMayorista6, precioMayorista80, enOfertaVenta, 
    porcentajeDescuento, tallasStock, colores, imagenes, categoriaNombre
  ];
}
