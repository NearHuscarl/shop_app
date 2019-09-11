import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'product.dart';
import '../models/http_exception.dart';
import '../utilities/sample_products.dart';

class Products with ChangeNotifier {
  final uuid = Uuid();
  List<Product> _items = [];
  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get favoriteItems {
    return _items.where((p) => p.isFavorite).toList();
  }

  List<Product> get items {
    return [..._items];
  }

  Future<void> fetchProducts([bool filterByUser = false]) async {
    final filterStr = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = '${Constants.DatabaseUrl}/products.json?auth=$authToken&$filterStr';
    final response = await http.get(url);
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null) return;

    url = '${Constants.DatabaseUrl}/userFavorites/$userId.json?auth=$authToken';
    final favoriteResponse = await http.get(url);
    final favoriteData = json.decode(favoriteResponse.body);
    final List<Product> loadedProducts = [];

    extractedData.forEach((productId, productData) {
      loadedProducts.add(Product(
        id: productId,
        title: productData['title'],
        description: productData['description'],
        price: productData['price'],
        isFavorite: favoriteData == null ? false : (favoriteData[productId] ?? false),
        imageUrl: productData['imageUrl'],
      ));
    });

    _items = loadedProducts;
    notifyListeners();
  }

  Future<void> addProduct(Product item) async {
    final url = '${Constants.DatabaseUrl}/products.json?auth=$authToken';
    final response = await http.post(url,
        body: json.encode({
          'title': item.title,
          'description': item.description,
          'price': item.price,
          'imageUrl': item.imageUrl,
          'creatorId': userId,
        }));

    if (response.statusCode >= 400) {
      throw HttpException(json.decode(response.body)['error']);
    }

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
      final url = '${Constants.DatabaseUrl}/products/$id.json?auth=$authToken';
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
    final url = '${Constants.DatabaseUrl}/products/$id.json?auth=$authToken';
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
