import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'product.dart';
import '../utilities/sample_products.dart';

class Products with ChangeNotifier {
  final uuid = Uuid();
  List<Product> _items = sampleProducts;

  List<Product> get favoriteItems {
    return _items.where((p) => p.isFavorite).toList();
  }

  List<Product> get items {
    return [..._items];
  }

  void addProduct(Product item) {
    final product = Product(
      id: uuid.v1(),
      title: item.title,
      description: item.description,
      imageUrl: item.imageUrl,
    );
    _items.add(product);
    notifyListeners();
  }

  void editProduct(String id, Product product) {
    final editedIndex = _items.indexWhere((p) => p.id == id);

    if (editedIndex >= 0) {
      _items[editedIndex] = product;
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    _items.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  Product findById(String id) {
    return _items.firstWhere((p) => p.id == id);
  }
}
