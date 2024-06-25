import 'package:flutter/material.dart';
import 'package:hello_way/models/product.dart';
import 'package:hello_way/view_model/list_products_by_category_view_model.dart';
import 'package:hello_way/view_model/menu_view_model.dart';
import 'package:hello_way/widgets/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../res/app_colors.dart';
import '../../services/network_service.dart';
import '../../widgets/card_menu.dart';

class ListProductsByCategory extends StatefulWidget {
  final int idCategory;

  const ListProductsByCategory({Key? key, required this.idCategory}) : super(key: key);

  @override
  State<ListProductsByCategory> createState() => _ListProductsByCategoryState();
}

class _ListProductsByCategoryState extends State<ListProductsByCategory> {
  late final ListProductsViewModel _listProductsViewModel;
  late MenuViewModel _menuViewModel;

  List<Product> _products = [];
  String title = "";

  Future<void> _fetchProducts() async {
    var category = await _listProductsViewModel.getCategorieId(widget.idCategory);
    title = category.categoryTitle;
    var fetchedProducts = await _menuViewModel.getProductsByIdCategory(widget.idCategory);
    setState(() {
      _products = fetchedProducts;
    });
  }

  @override
  void initState() {
    super.initState();
    _listProductsViewModel = ListProductsViewModel(context);
    _menuViewModel = MenuViewModel(context);
    _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return Scaffold(
      appBar: Toolbar(title: title),
      body: networkStatus == NetworkStatus.Online
          ? _products.isNotEmpty
          ? GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2 / 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _products.length,
        itemBuilder: (ctx, i) => CardMenu(product: _products[i]),
      )
          : const Center(
        child: CircularProgressIndicator(),
      )
          : Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.network_check,
                size: 150,
                color: gray,
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.noInternet,
                style: const TextStyle(fontSize: 22, color: gray),
                textAlign: TextAlign.center,
              ),
              Text(
                AppLocalizations.of(context)!.checkYourInternet,
                style: const TextStyle(fontSize: 22, color: gray),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              MaterialButton(
                color: orange,
                height: 40,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                onPressed: () {
                  setState(() {
                    _fetchProducts();
                  });
                },
                child: Text(
                  AppLocalizations.of(context)!.retry,
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
