import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';
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
  List<Order> _orders = [];

  List<Order> get orders {
    return [..._orders];
  }

  void addOrder(List<Cart> products, double total) {
    _orders.insert(
        0,
        Order(
          id: uuid.v1(),
          amount: total,
          date: DateTime.now(),
          products: products,
        ));
    notifyListeners();
  }
}
