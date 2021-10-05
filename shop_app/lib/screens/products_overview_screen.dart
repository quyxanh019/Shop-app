import 'package:flutter/material.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/badge.dart';
import 'package:shop_app/widgets/products_grid.dart';

enum FilterOptions {
  Favorite,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;
  late Future _productsFuture;

  Future _obtainProductsFuture() {
    return Provider.of<Products>(context, listen: false).fetchAndSetProducts();
  }

  @override
  void initState() {
    _productsFuture = _obtainProductsFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //final productContainer = Provider.of<Products>(context, listen: false);
    print("build product overview");
    return Scaffold(
      appBar: AppBar(
        title: const Text("MyShop"),
        actions: [
          PopupMenuButton(
              onSelected: (selectedValue) {
                setState(() {
                  if (selectedValue == FilterOptions.Favorite) {
                    _showOnlyFavorites = true;
                  } else {
                    _showOnlyFavorites = false;
                  }
                });
              },
              child: const Icon(Icons.more_vert),
              itemBuilder: (_) => [
                    const PopupMenuItem(
                      child: Text("Only favorite"),
                      value: FilterOptions.Favorite,
                    ),
                    const PopupMenuItem(
                      child: Text("Show all"),
                      value: FilterOptions.All,
                    ),
                  ]),
          Consumer<Cart>(
            builder: (_, cart, child) => Badge(
              value: cart.itemCount.toString(),
              child: child!,
            ),
            child: IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
                icon: const Icon(Icons.shopping_cart)),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
          future: _productsFuture,
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (dataSnapshot.error != null) {
                print(dataSnapshot.data.toString());
                print(dataSnapshot.error);
                // Do error handling
                return const Center(
                  child: Text("An error"),
                );
              } else {
                return ProductsGrid(_showOnlyFavorites);
              }
            }
          }),
    );
  }
}
