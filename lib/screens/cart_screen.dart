import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/carts.dart';
import '../providers/orders.dart';
import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final carts = Provider.of<Carts>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: TextStyle(fontSize: 20)),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$${carts.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context).primaryTextTheme.title.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  FlatButton(
                    child: Text('Order Now'),
                    onPressed: () {
                      Provider.of<Orders>(context, listen: false).addOrder(
                        carts.items.values.toList(),
                        carts.totalAmount,
                      );
                      carts.clear();
                    },
                    textColor: Theme.of(context).primaryColor,
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: carts.itemCount,
              itemBuilder: (context, index) {
                final cart = carts.items.values.toList()[index];
                final productIds = carts.items.keys.toList()[index];

                return CartItem(
                  id: cart.id,
                  productId: productIds,
                  title: cart.title,
                  price: cart.price,
                  quantity: cart.quantity,
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
