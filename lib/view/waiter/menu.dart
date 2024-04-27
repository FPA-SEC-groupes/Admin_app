import 'package:flutter/material.dart';
import 'package:hello_way/models/command.dart';
import 'package:hello_way/models/product.dart';
import 'package:hello_way/res/app_colors.dart';
import 'package:hello_way/shimmer/item_product_shimmer.dart';
import 'package:hello_way/widgets/categories_tab_bar.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/category.dart';
import '../../services/network_service.dart';
import '../../utils/secure_storage.dart';
import '../../view_model/menu_view_model.dart';
import '../../widgets/item_product.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final SecureStorage secureStorage = SecureStorage();
  late final MenuViewModel _menuViewModel ;
  final ValueNotifier<int> selectedCategoryIndexNotifier = ValueNotifier<int>(0);
  ValueNotifier<int?>? selectedCategoryIdNotifier ;

  bool _isSearching = false;
  String _searchQuery = '';
  @override
  void initState() {
    super.initState();
    _menuViewModel = MenuViewModel(context);
    _fetchCategories().then((categories) {
      setState(() {
        selectedCategoryIdNotifier = ValueNotifier<int>(categories[0].id_category!);
        print(selectedCategoryIdNotifier!.value);
      });
    });
  }

  Future<List<Category>> _fetchCategories() async {
    // Fetch categories from a data source (e.g., database or API)
    List<Category> categories = await _menuViewModel.getCategoriesByIdSpace();


    return categories;
  }

  Future<List<Product>> _getProductsByIdCategory(int categoryId) async {
    List<Product> products =
        await _menuViewModel.getProductsByIdCategory(categoryId);
    return products;
  }



  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return Scaffold(
      appBar: AppBar(
        title:_isSearching
          ? TextField(
          onChanged: (value) {
    setState(() {
    _searchQuery = value;
    });
    },
      decoration:  InputDecoration(
        hintText: AppLocalizations.of(context)!.search,
        border: InputBorder.none,
      ),
    )
        :   Text(AppLocalizations.of(context)!.menu,
    ),
    elevation: 1,
        automaticallyImplyLeading:false ,


        actions: [
          Padding(
              padding: const EdgeInsets.all(10),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                child: const Icon(
                  Icons.search,
                  color: Colors.white,
                ),
              ))
        ],
      ),
      body: networkStatus == NetworkStatus.Online
          ?Row(
        children: [
          FutureBuilder(
            future: _fetchCategories(),
            builder:
                (BuildContext context, AsyncSnapshot<List<Category>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  width: 100,
                  child:ListView.builder(
                    itemCount: 15,

                    itemBuilder: (context, index) {
                      return  Container(


                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          border: Border(

                            bottom: BorderSide(
                              color: lightGray,
                              width: 2.0,
                            ),
                          ),
                        ),
                        child:  Shimmer.fromColors(
                          baseColor: gray.withOpacity(0.5),
                          highlightColor: Colors.white,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,

                            ),
                            height: 10,
                            width: MediaQuery.of(context).size.width / 2,
                          ),
                        ),
                      );
                    },

                  ),
                );
              } else if (snapshot.hasError) {
                return  Center(
                  child: Text(AppLocalizations.of(context)!.errorRetrievingData),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center();
              } else {
                final categories = snapshot.data!;
                final List<String> categoryNames = categories
                    .map((category) => category.categoryTitle)
                    .toList();
                return ValueListenableBuilder(
                    valueListenable: selectedCategoryIndexNotifier,
                    builder: (context, selectedIndex, _) {


                      return CategoriesTabBar(
                      onChanged: (index) {
                        selectedCategoryIndexNotifier.value = index;
                        print(categories[index].id_category);


                        final selectedCategory = categories[index     ];
                        selectedCategoryIdNotifier!.value = selectedCategory.id_category;
                        print(selectedCategory.id_category);
                      },
                      selectedIndex: selectedIndex,
                      items: categoryNames,
                      );
                    });
              }
            },
          ),
          Container(
            color: lightGray,
            width: 10,
          ),
          if (selectedCategoryIdNotifier?.value!=null)
            Expanded(
              child: ValueListenableBuilder(
              valueListenable: selectedCategoryIdNotifier!,
              builder: (context, selectedIndex, _) {
                return FutureBuilder(
                future: _getProductsByIdCategory(  selectedCategoryIdNotifier!.value!),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Product>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView.separated(
                      itemCount: 10,
                      separatorBuilder: (context, index) =>   Container(color:lightGray,height: 10),
                      itemBuilder: (context, index) {
                        return const ItemProductShimmer() ;
                      },
                    );
                  } else if (snapshot.hasError) {
                    return  Center(
                      child: Text(AppLocalizations.of(context)!.errorRetrievingData),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center();
                  } else {
                    final List<Product> products;
                    if (_searchQuery.isEmpty) {
                       products = snapshot.data!;
                    } else {
                      products = (snapshot.data!)
                          .where((product) => product.productTitle
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                          .toList();
                    }
                    return ListView.separated(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        Product product = products[index];
                        return ItemProduct( product: product,);
                      },
                      separatorBuilder: (context, index) {
                        return Container(
                          color: lightGray,
                          height: 10,
                        );
                      },
                    );
                  }
                },
              );})
            ),
        ],
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
