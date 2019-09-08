import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'product_item.dart';
import '../providers/products.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavorite;

  const ProductsGrid(this.showFavorite);

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<Products>(context);
    final products = showFavorite ? productData.favoriteItems : productData.items;

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: products.length,
      itemBuilder: (context, index) {
        var product = products[index];
        return ChangeNotifierProvider.value(
          value: product,
          child: ProductItem(),
        );
      },
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}
