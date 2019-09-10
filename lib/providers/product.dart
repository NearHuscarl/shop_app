import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

class Product with ChangeNotifier {
  static const baseUrl = 'https://flutter-shop-app-e04cc.firebaseio.com';

  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavorite() async {
    final url = '$baseUrl/products/$id';
    final newFavorite = !isFavorite;
    final response = await http.patch(
      url,
      body: json.encode({
        'isFavorite': newFavorite,
      }),
    );

    if (response.statusCode >= 400) {
      throw HttpException('Could not toggle favorite.');
    }

    isFavorite = newFavorite;
    notifyListeners();
  }
}
