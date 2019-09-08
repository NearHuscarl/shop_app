import 'package:flutter/material.dart';
import 'product.dart';
import '../utilities/sample_products.dart';

class Products with ChangeNotifier {
  List<Product> _items = sampleProducts;

  List<Product> get favoriteItems {
    return _items.where((p) => p.isFavorite).toList();
  }

  List<Product> get items {
    return [..._items];
  }

  void addProduct(Product item) {
    _items.add(item);
    notifyListeners();
  }

  Product findById(String id) {
    return _items.firstWhere((p) => p.id == id);
  }
}