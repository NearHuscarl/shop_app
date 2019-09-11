import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_product_item.dart';
import '../providers/products.dart';
import 'edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          )
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (context, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => _refreshProducts(context),
                child: Consumer<Products>(
                  builder: (context, productData, child) => Padding(
                    padding: EdgeInsets.all(8),
                    child: ListView.builder(
                      itemCount: productData.items.length,
                      itemBuilder: (context, index) {
                        final product = productData.items[index];
                        return Column(
                          children: [
                            UserProductItem(
                                product.id, product.title, product.imageUrl),
                            Divider(),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
