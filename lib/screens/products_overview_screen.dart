import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/carts.dart';
import '../providers/products.dart';
import '../widgets/app_drawer.dart';
import '../widgets/badge.dart';
import '../widgets/products_grid.dart';
import 'cart_screen.dart';

enum FilterOption {
  Favorites,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isInit = false;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInit) {
      _isLoading = true;
      Provider.of<Products>(context).fetchProducts().then((_) {
        setState(() => _isLoading = false);
      });
      _isInit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOption selectedValue) {
              setState(() {
                if (selectedValue == FilterOption.Favorites) {
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOption.Favorites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOption.All,
              ),
            ],
          ),
          Consumer<Carts>(
            builder: (context, cart, child) => Badge(
              child: child,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showOnlyFavorites),
    );
  }
}
