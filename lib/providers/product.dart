import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/http_exception.dart';

class Product with ChangeNotifier {
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

  Future<void> toggleFavorite(String authToken, String userId) async {
    final url =
        '${Constants.DatabaseUrl}/userFavorites/$userId/$id.json?auth=$authToken';
    final newFavorite = !isFavorite;
    final response = await http.put(
      url,
      body: json.encode(newFavorite),
    );

    if (response.statusCode >= 400) {
      throw HttpException('Could not toggle favorite.');
    }

    isFavorite = newFavorite;
    notifyListeners();
  }
}
