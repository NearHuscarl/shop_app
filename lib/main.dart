import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/auth.dart';
import 'providers/products.dart';
import 'providers/carts.dart';
import 'providers/orders.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/products_overview_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/user_products_screen.dart';
import 'screens/edit_product_screen.dart';
import 'utilities/custom_route.dart';

Future main() async {
  await DotEnv().load('.env');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          builder: (context, auth, prevProducts) => Products(
            auth.token,
            auth.userId,
            prevProducts == null ? [] : prevProducts.items,
          ),
        ),
        ChangeNotifierProvider.value(
          value: Carts(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          builder: (context, auth, prevOrders) => Orders(
            auth.token,
            auth.userId,
            prevOrders == null ? [] : prevOrders.items,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (context, auth, child) {
          return MaterialApp(
            title: 'MyShop',
            theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
              fontFamily: 'Lato',
              pageTransitionsTheme: PageTransitionsTheme(builders: {
                TargetPlatform.android: CustomPageTransitionBuilder(),
                TargetPlatform.iOS: CustomPageTransitionBuilder(),
              }),
            ),
            home: auth.isAuth
                ? ProductsOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (context, snapshot) =>
                        snapshot.connectionState == ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen(),
                  ),
            routes: {
              AuthScreen.routeName: (context) => AuthScreen(),
              ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
              CartScreen.routeName: (context) => CartScreen(),
              OrdersScreen.routeName: (context) => OrdersScreen(),
              UserProductsScreen.routeName: (context) => UserProductsScreen(),
              EditProductScreen.routeName: (context) => EditProductScreen(),
            },
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProductsOverviewScreen();
  }
}
