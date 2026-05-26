import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;

  ProductRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await dio.get(AppConstants.products);
    
    if (response.statusCode == 200) {
      final List data = response.data['data']['products'];
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener productos');
    }
  }
}
