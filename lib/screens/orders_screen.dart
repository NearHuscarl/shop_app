import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart';
import '../widgets/app_drawer.dart';
import '../widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Your Orders'),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future: Provider.of<Orders>(context, listen: false).fetchOrders(),
          builder: (context, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (dataSnapshot.error == null) {
                return Consumer<Orders>(
                  builder: (context, orderData, child) {
                    return ListView.builder(
                      itemCount: orderData.items.length,
                      itemBuilder: (context, index) {
                        return OrderItem(orderData.items[index]);
                      },
                    );
                  },
                );
              } else {
                return Center(child: Text('An error occured!'));
              }
            }
          },
        ));
  }
}
