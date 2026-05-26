import '../../domain/entities/category.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    super.description,
    super.imageUrl,
    required super.status,
    required super.totalProducts,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['nombre'],
      description: json['descripcion'],
      imageUrl: json['imagenUrl'],
      status: json['estado'] ?? true,
      totalProducts: json['totalProductos'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': name,
      'descripcion': description,
      'imagenUrl': imageUrl,
      'estado': status,
      'totalProductos': totalProducts,
    };
  }
}
