import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final bool status;
  final int totalProducts;

  const CategoryEntity({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.status,
    required this.totalProducts,
  });

  @override
  List<Object?> get props => [id, name, description, imageUrl, status, totalProducts];
}
