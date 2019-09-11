import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/carts.dart';
import '../providers/product.dart';
import '../providers/auth.dart';
import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final carts = Provider.of<Carts>(context, listen: false);
    final scaffold = Scaffold.of(context);
    final theme = Theme.of(context);
    final authData = Provider.of<Auth>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            builder: (context, product, _) => IconButton(
              icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border),
              onPressed: () async {
                try {
                  await product.toggleFavorite(authData.token, authData.userId);
                } catch (error) {
                  scaffold.showSnackBar(SnackBar(
                    content: Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                    ),
                    backgroundColor: theme.errorColor,
                  ));
                }
              },
              color: Theme.of(context).accentColor,
            ),
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              carts.addItem(product.id, product.title, product.price);
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text(
                  'Added item to cart!',
                ),
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () {
                    carts.removeSingleItem(product.id);
                  },
                ),
                duration: Duration(seconds: 2),
              ));
            },
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}
