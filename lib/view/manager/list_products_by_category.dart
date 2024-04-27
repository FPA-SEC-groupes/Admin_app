import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hello_way/models/product.dart';
import 'package:hello_way/view_model/list_products_by_category_view_model.dart';
import 'package:hello_way/widgets/app_bar.dart';
import 'package:provider/provider.dart';

import '../../res/app_colors.dart';
import '../../services/network_service.dart';
import '../../widgets/card_menu.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class ListProductsByCategory extends StatefulWidget {

  final int idCategory;
  const ListProductsByCategory({Key? key, required this.idCategory}) : super(key: key);

  @override
  State<ListProductsByCategory> createState() => _ListProductsByCategoryState();
}

class _ListProductsByCategoryState extends State<ListProductsByCategory> {

  late final ListProductsViewModel _listProductsViewModel;


  List<Product> _products = [];
   String title="";



  Future<void> _fetchProducts() async {
    // fetch the list of categories using the HomeViewModel
    var category = await _listProductsViewModel.getCategorieId(widget.idCategory);
    title=category.categoryTitle;
    setState(() {
      _products = _products;
    });
  }
  @override
  void initState() {
    super.initState();
    _listProductsViewModel = ListProductsViewModel(context);
    _fetchProducts();
  }


  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return Scaffold(
      appBar:Toolbar(title:  title),


      body:networkStatus == NetworkStatus.Online
          ? FutureBuilder(
        future: _listProductsViewModel.getCategorieId(widget.idCategory),
        builder: (BuildContext context,snapshot) {
          if(snapshot.hasData) {
            return GridView.builder(
              itemCount: _products.length,
              itemBuilder: (BuildContext context, int index) {
                final product = _products[index];
                return Padding(
                  padding: const EdgeInsets.all(5),
                  child: CardMenu(product: product,

                  ),
                );
              },
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                mainAxisExtent: 200,
              ),
            );
          }
          else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ):Center(
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
              SizedBox(height: 10,),
              MaterialButton(
                color: orange,
                height: 40,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                onPressed:(){
                  setState(() {

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
