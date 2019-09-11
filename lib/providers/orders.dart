import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/http_exception.dart';
import 'carts.dart';

class Order {
  final String id;
  final double amount;
  final List<Cart> products;
  final DateTime date;

  Order({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.date,
  });
}

class Orders with ChangeNotifier {
  final uuid = Uuid();
  List<Order> _items = [];
  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._items);

  List<Order> get items {
    return [..._items];
  }

  Future<void> addOrder(List<Cart> products, double total) async {
    final url = '${Constants.DatabaseUrl}/orders/$userId.json?auth=$authToken';
    final timestamp = DateTime.now();
    final response = await http.post(
      url,
      body: json.encode({
        'amount': total,
        'date': timestamp.toIso8601String(),
        'products': products
            .map((p) => ({
                  'id': p.id,
                  'title': p.title,
                  'quantity': p.quantity,
                  'price': p.price,
                }))
            .toList(),
      }),
    );

    if (response.statusCode >= 400) {
      throw HttpException(json.decode(response.body)['error']);
    }

    final order = Order(
      id: json.decode(response.body)['name'],
      amount: total,
      date: timestamp,
      products: products,
    );
    _items.insert(0, order);
    notifyListeners();
  }

  Future<void> fetchOrders() async {
    final url = '${Constants.DatabaseUrl}/orders/$userId.json?auth=$authToken';
    final response = await http.get(url);
    final List<Order> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null) return;

    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(Order(
        id: orderId,
        amount: orderData['amount'],
        products: (orderData['products'] as List<dynamic>).map((c) {
          return Cart(
            id: c['id'],
            title: c['title'],
            price: c['price'],
            quantity: c['quantity'],
          );
        }).toList(),
        date: DateTime.parse(orderData['date']),
      ));
    });

    _items = loadedOrders.reversed.toList();
    notifyListeners();
  }
}
