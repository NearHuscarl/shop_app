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
                  OrderButton(carts),
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

class OrderButton extends StatefulWidget {
  final Carts carts;

  OrderButton(this.carts);

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Text('Order Now'),
      onPressed: (widget.carts.items.length <= 0 || _isLoading)
          ? null
          : () async {
              setState(() => _isLoading = true);
              try {
                await Provider.of<Orders>(context, listen: false).addOrder(
                  widget.carts.items.values.toList(),
                  widget.carts.totalAmount,
                );
                widget.carts.clear();
                setState(() => _isLoading = false);
              } catch (error) {
                setState(() => _isLoading = false);
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('An error occurred!'),
                    content: Text('Could not add order.'),
                    actions: [
                      FlatButton(
                        child: Text('Okay'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                );
              }
            },
      textColor: Theme.of(context).primaryColor,
    );
  }
}
