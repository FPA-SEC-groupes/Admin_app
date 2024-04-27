import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:draggable_fab/draggable_fab.dart';
import 'package:flutter/material.dart';
import 'package:hello_way/models/category.dart';
import 'package:hello_way/models/product.dart';
import 'package:hello_way/utils/routes.dart';
import 'package:hello_way/view/manager/product_details.dart';
import 'package:hello_way/widgets/custom_alert_dialog.dart';
import 'package:hello_way/widgets/card_menu.dart';
import 'package:provider/provider.dart';
import '../../res/app_colors.dart';
import '../../services/network_service.dart';
import '../../shimmer/card_menu_shimmer.dart';
import '../../utils/const.dart';
import '../../utils/secure_storage.dart';
import '../../view_model/menu_view_model.dart';
import '../../widgets/custom_app_bar_with_search.dart';
import '../../widgets/dialog.dart';
import 'add_new_promotion.dart';
import 'list_products_by_category.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final SecureStorage secureStorage = SecureStorage();
  late MenuViewModel _menuViewModel;
  late final TextEditingController _titleCategoryController =
      TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  String? errorText;
  @override
  void initState() {
    _menuViewModel = MenuViewModel(context);
    _fetchCategories();
    super.initState();
  }

  @override
  void dispose() {
    _titleCategoryController.dispose();
    super.dispose();
  }

  Future<List<Category>> _fetchCategories() async {
    List<Category> categories = await _menuViewModel.getCategoriesByIdSpace();
    return categories;
  }

  String? _validateCategoryTitle(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.inputRequiredError;
    } else if (errorText != null) {
      return AppLocalizations.of(context)!.catgoryAlreadyExists;
    }
    return null;
  }

  Future<void> actionPopUpItemSelected(String value, Category category) async {
    if (value == showMore) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ListProductsByCategory(
                  idCategory: category.id_category!,
                )),
      );
    } else if (value == delete) {
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomAlertDialog(
                title: AppLocalizations.of(context)!.deleteCategoryDialogTitle,
                message: AppLocalizations.of(context)!.deleteCategoryMessage,
                submit: () {
                  _menuViewModel
                      .deleteCategorie(category.id_category!)
                      .then((_) async {
                    setState(() {
                      _fetchCategories();
                    });
                    Navigator.of(context).pop();
                  }).catchError((error) {});
                },
                cancel: () {
                  Navigator.of(context).pop();
                },
                textSubmitButton: AppLocalizations.of(context)!.delete,
                textCancelButton: AppLocalizations.of(context)!.cancel);
          });
    } else if (value == add) {
      await secureStorage.writeData(
          categoryId, category.id_category!.toString());

     final resulat=await Navigator.pushNamed(context, addProductRoute);
     if(resulat!=null){
       setState(() {
         _fetchCategories();
       });
     }
    } else if (value == edit) {
      errorText = null; // Set the errorText to display the error message
      _titleCategoryController.text = category.categoryTitle;
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, update) {
              return CustomDialog(
                title: AppLocalizations.of(context)!.renameCategoryTitle,
                validator: _validateCategoryTitle,
                controller: _titleCategoryController,
                hint: AppLocalizations.of(context)!.title,
                keyboardType: TextInputType.text,
                message: AppLocalizations.of(context)!.renameCategoryMessage,
                submit: () async {
                  category.categoryTitle = _titleCategoryController.text.trim();

                  await _menuViewModel
                      .updateCategory(category)
                      .then((categorie) async {
                    setState(() {
                      _fetchCategories();
                    });
                    Navigator.of(context).pop();
                  }).catchError((error) {
                    if (error is DioError) {
                      if (error.response?.statusCode == 400) {
                        // Handle 400 status code error (Bad Request)
                        update(() {
                          errorText = AppLocalizations.of(context)!
                              .catgoryAlreadyExists;
                          print(errorText);
                        });
                      }
                    } else {
                      // Handle other errors
                      print("Error: $error");
                    }
                  });
                },
                cancel: () {
                  Navigator.of(context).pop();
                },
              );
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return Scaffold(
      backgroundColor: lightGray,
      appBar: CustomAppBarWithSearch(
        title: AppLocalizations.of(context)!.menu,
        isSearching: _isSearching,
        hintText: AppLocalizations.of(context)!.searchForCategory,
        onSearchChanged: (String value) {
          setState(() {
            _searchQuery = value;
          });
        },
        onSearchToggle: () {
          setState(() {
            _isSearching = !_isSearching;
            _searchQuery = '';
          });
        },
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: DraggableFab(
    child:FloatingActionButton(
        backgroundColor: orange,
        onPressed: () async {
          errorText = null; // Set the errorText to display the error message

          _titleCategoryController.clear();
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(builder: (context, update) {
                return CustomDialog(
                  title: AppLocalizations.of(context)!.addCategoryTitle,
                  validator: _validateCategoryTitle,
                  controller: _titleCategoryController,
                  submit: () async {
                    String categoryTitle = _titleCategoryController.text.trim();
                    await _menuViewModel
                        .addCategoryByIdSpace(context, categoryTitle)
                        .then((categorie) async {
                      setState(() {
                        _fetchCategories();
                      });
                      Navigator.of(context).pop();
                    }).catchError((error) {
                      if (error is DioError) {
                        if (error.response?.statusCode == 400) {
                          // Handle 400 status code error (Bad Request)
                          update(() {
                            errorText = AppLocalizations.of(context)!
                                .catgoryAlreadyExists;
                            print(errorText);
                          });
                        }
                      } else {
                        // Handle other errors
                        print("Error: $error");
                      }
                    });
                  },
                  cancel: () {
                    Navigator.of(context).pop();
                  },
                  hint: AppLocalizations.of(context)!.title,
                  keyboardType: TextInputType.text,
                );
              });
            },
          );

          // Do something when the button is pressed
        },
        child: const Icon(Icons.add),
      ),),
      body: networkStatus == NetworkStatus.Online
          ? FutureBuilder(
              future: _fetchCategories(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.category_rounded,
                            size: 150,
                            color: gray,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            AppLocalizations.of(context)!.noCategoriesInSpace,
                            style: const TextStyle(fontSize: 22, color: gray),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  final List<Category> categories;
                  if (_searchQuery.isEmpty) {
                    categories = snapshot.data!;
                  } else {
                    categories = (snapshot.data! as List<Category>)
                        .where((category) => category.categoryTitle
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()))
                        .toList();
                  }
                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (BuildContext context, int index) {
                      final category = categories[index];
                      return FutureBuilder<List<Product>>(
                        future: _menuViewModel
                            .getProductsByIdCategory(category.id_category!),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Product>> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          category.categoryTitle
                                                  .substring(0, 1)
                                                  .toUpperCase() +
                                              category.categoryTitle
                                                  .substring(1),
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                        PopupMenuButton<String>(
                                          color: Colors.white,
                                          offset: const Offset(0, 40),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          onSelected: (String value) =>
                                              actionPopUpItemSelected(
                                                  value, category),
                                          itemBuilder: (BuildContext context) =>
                                              <PopupMenuEntry<String>>[
                                            PopupMenuItem<String>(
                                              value: add,
                                              child: ListTile(
                                                minLeadingWidth: 10,
                                                contentPadding: EdgeInsets.zero,
                                                leading: const Icon(Icons.add),
                                                title: Text(AppLocalizations.of(
                                                        context)!
                                                    .addProduct),
                                              ),
                                            ),
                                            PopupMenuItem<String>(
                                              value: showMore,
                                              child: ListTile(
                                                minLeadingWidth: 10,
                                                contentPadding: EdgeInsets.zero,
                                                leading: const Icon(
                                                    Icons.read_more_rounded),
                                                title: Text(AppLocalizations.of(
                                                        context)!
                                                    .showMore),
                                              ),
                                            ),
                                            PopupMenuItem<String>(
                                              value: edit,
                                              child: ListTile(
                                                minLeadingWidth: 10,
                                                contentPadding: EdgeInsets.zero,
                                                leading: const Icon(Icons.edit),
                                                title: Text(AppLocalizations.of(
                                                        context)!
                                                    .rename),
                                              ),
                                            ),
                                            PopupMenuItem<String>(
                                              value: delete,
                                              child: ListTile(
                                                minLeadingWidth: 10,
                                                contentPadding: EdgeInsets.zero,
                                                leading: const Icon(
                                                    Icons.delete_outline),
                                                title: Text(AppLocalizations.of(
                                                        context)!
                                                    .delete),
                                              ),
                                            ),
                                          ],
                                          icon: const Icon(
                                            Icons.more_vert_rounded,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 210,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: 3,
                                      itemBuilder: (context, index) {
                                        return const Padding(
                                            padding: EdgeInsets.only(
                                                left: 5, right: 5, bottom: 10),
                                            child: CardMenuShimmer());
                                      },
                                    ),
                                  )
                                ]);
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text(snapshot.error.toString()),
                            );
                          } else {
                            final products = snapshot.data!;
                            return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          category.categoryTitle
                                                  .substring(0, 1)
                                                  .toUpperCase() +
                                              category.categoryTitle
                                                  .substring(1),
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                        PopupMenuButton<String>(
                                          color: Colors.white,
                                          offset: const Offset(0, 40),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          onSelected: (String value) =>
                                              actionPopUpItemSelected(
                                                  value, category),
                                          itemBuilder: (BuildContext context) =>
                                              <PopupMenuEntry<String>>[
                                            PopupMenuItem<String>(
                                              value: add,
                                              child: ListTile(
                                                minLeadingWidth: 10,
                                                contentPadding: EdgeInsets.zero,
                                                leading: const Icon(Icons.add),
                                                title: Text(AppLocalizations.of(
                                                        context)!
                                                    .addProduct),
                                              ),
                                            ),
                                            PopupMenuItem<String>(
                                              value: showMore,
                                              child: ListTile(
                                                minLeadingWidth: 10,
                                                contentPadding: EdgeInsets.zero,
                                                leading: const Icon(
                                                    Icons.read_more_rounded),
                                                title: Text(AppLocalizations.of(
                                                        context)!
                                                    .showMore),
                                              ),
                                            ),
                                            PopupMenuItem<String>(
                                              value: edit,
                                              child: ListTile(
                                                minLeadingWidth: 10,
                                                contentPadding: EdgeInsets.zero,
                                                leading: const Icon(Icons.edit),
                                                title: Text(AppLocalizations.of(
                                                        context)!
                                                    .rename),
                                              ),
                                            ),
                                            PopupMenuItem<String>(
                                              value: delete,
                                              child: ListTile(
                                                minLeadingWidth: 10,
                                                contentPadding: EdgeInsets.zero,
                                                leading: const Icon(
                                                    Icons.delete_outline),
                                                title: Text(AppLocalizations.of(
                                                        context)!
                                                    .delete),
                                              ),
                                            ),
                                          ],
                                          icon: const Icon(
                                            Icons.more_vert_rounded,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  products.isNotEmpty
                                      ? SizedBox(
                                          height: 230,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: products.length,
                                            itemBuilder: (context, index) {
                                              var product = products[index];
                                              return GestureDetector(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5,
                                                          right: 5,
                                                          bottom: 10),
                                                  child: CardMenu(
                                                    product: product,
                                                    onTap: () {
                                                      product.promotionId == 0
                                                          ? Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        AddNewPromotion(
                                                                  product:
                                                                      product,
                                                                ),
                                                              ),
                                                            ).then((value) {
                                                              setState(() {
                                                                _fetchCategories();
                                                              });
                                                            })
                                                          : Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        AddNewPromotion(
                                                                  product:
                                                                      product,
                                                                  promotionId:
                                                                      product
                                                                          .promotionId,
                                                                )
                                                              )).then((value) {
                                                        setState(() {
                                                          _fetchCategories();
                                                        });
                                                      });
                                                    },
                                                  ),
                                                ),
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProductDetails(
                                                        product: product,
                                                            updateProduct: (updatedProduct) {
                                                              setState(() {
                                                                product = updatedProduct; // Update the local 'product' variable
                                                              });
                                                            },
                                                      ),
                                                    ),
                                                  ).then((value) {
                                                    setState(() {
                                                      _fetchCategories();
                                                    });
                                                  });
                                                },
                                              );
                                            },
                                          ),
                                        )
                                      : Padding(
                                          padding: EdgeInsets.only(
                                              left: 10, right: 10, bottom: 10),
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .noProductsInThisCategory))
                                ]);
                          }
                        },
                      );
                    },
                  );
                }
              },
            )
          :Center(
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
