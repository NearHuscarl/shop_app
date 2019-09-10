import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'product.dart';
import '../models/http_exception.dart';
import '../utilities/sample_products.dart';

class Products with ChangeNotifier {
  final uuid = Uuid();
  static const baseUrl = 'https://flutter-shop-app-e04cc.firebaseio.com';
  List<Product> _items = [];

  List<Product> get favoriteItems {
    return _items.where((p) => p.isFavorite).toList();
  }

  List<Product> get items {
    return [..._items];
  }

  Future<void> fetchProducts() async {
    const url = '$baseUrl/products.json';
    final response = await http.get(url);
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    final List<Product> loadedProducts = [];

    if (extractedData == null) return;

    extractedData.forEach((productId, productData) {
      loadedProducts.add(Product(
        id: productId,
        title: productData['title'],
        description: productData['description'],
        price: productData['price'],
        imageUrl: productData['imageUrl'],
        isFavorite: productData['isFavorite'],
      ));
    });

    _items = loadedProducts;
    notifyListeners();
  }

  Future<void> addProduct(Product item) async {
    const url = '$baseUrl/products.json';
    final response = await http.post(url,
        body: json.encode({
          'title': item.title,
          'description': item.description,
          'price': item.price,
          'imageUrl': item.imageUrl,
          'isFavorite': item.isFavorite,
        }));

    final product = Product(
      id: json.decode(response.body)['name'],
      title: item.title,
      description: item.description,
      price: item.price,
      imageUrl: item.imageUrl,
    );
    _items.add(product);
    notifyListeners();
  }

  Future<void> editProduct(String id, Product product) async {
    final editedIndex = _items.indexWhere((p) => p.id == id);

    if (editedIndex >= 0) {
      final url = '$baseUrl/products/$id.json';
      final response = await http.patch(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
        }),
      );

      if (response.statusCode >= 400) {
        throw HttpException('Could not update product.');
      }

      _items[editedIndex] = product;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = '$baseUrl/products/$id.json';
    final existingProductIndex = _items.indexWhere((p) => p.id == id);
    var existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);

    // delete does not throw error if we get error status code from the server
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }

    existingProduct = null;
  }

  Product findById(String id) {
    return _items.firstWhere((p) => p.id == id);
  }
}
