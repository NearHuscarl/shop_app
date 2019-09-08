import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class Cart {
  final String id;
  final String title;
  final int quantity;
  final double price;

  Cart({
    @required this.id,
    @required this.title,
    @required this.price,
    @required this.quantity,
  });
}

class Carts with ChangeNotifier {
  final uuid = Uuid();
  Map<String, Cart> _items = {};

  Map<String, Cart> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;

    _items.forEach((key, cart) => total += cart.price * cart.quantity);

    return total;
  }

  void addItem(String productId, String title, double price) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (old) => Cart(
          id: old.id,
          title: old.title,
          price: old.price,
          quantity: old.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => Cart(
          id: uuid.v1(),
          title: title,
          price: price,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId].quantity > 1) {
      _items.update(
          productId,
          (old) => Cart(
                id: old.id,
                title: old.title,
                price: old.price,
                quantity: old.quantity - 1,
              ));
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
