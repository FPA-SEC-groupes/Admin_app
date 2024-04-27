import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hello_way/models/product.dart';
import 'package:hello_way/view/manager/add_new_promotion.dart';
import 'package:hello_way/view/manager/add_product.dart';
import 'package:hello_way/widgets/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../res/app_colors.dart';
import '../../services/network_service.dart';
import '../../utils/const.dart';
import '../../view_model/products_view_model.dart';
import '../../widgets/custom_alert_dialog.dart';

class ProductDetails extends StatefulWidget {
   Product product;
   final Function(Product) updateProduct;
   ProductDetails({Key? key, required this.product, required this.updateProduct}) : super(key: key);

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails>
    with SingleTickerProviderStateMixin {
 late  ProductsViewModel _productsViewModel;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _productsViewModel=ProductsViewModel(context);
  }
  Future<void> actionPopUpItemSelected(String value, Product product) async {
    if (value == edit) {
      final resulat=await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddProduct(
          product: product,
          ),
        ),
      );
      if(resulat!=null){
        setState(() {
          widget.updateProduct(resulat);
        });
      }

    } else if (value == delete) {
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomAlertDialog(
              title: AppLocalizations.of(context)!.deleteProductDialogTitle,
              message:AppLocalizations.of(context)!.deleteProductMessage,
              submit: () {
                _productsViewModel.deleteProduct(product.idProduct!).then((_) {
                  Navigator.of(context).pop(true);
                }).catchError((error) {
                  // Handle addBasketByTableId error here
                });
              },
              cancel: () {},
              textSubmitButton: AppLocalizations.of(context)!.delete,
              textCancelButton: AppLocalizations.of(context)!.cancel,
            );
          }).then((result) {
        if (result == true) {
          // If the dialog was submitted successfully (product deleted), you can navigate back to the previous screen.
          // For example, if you're using Navigator.pop to go back:
          Navigator.pop(context);
          setState(() {

          });// This will navigate back to the previous screen.
        }
        // If the dialog was canceled or an error occurred during deletion, no navigation will happen.
      });
    } else if (value == "promo") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddNewPromotion(
            product: product,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return Scaffold(
      appBar: Toolbar(
        title: "Details",
        actions: [
          PopupMenuButton<String>(
            color: Colors.white,
            elevation: 10,
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            onSelected: (String value) =>
                actionPopUpItemSelected(value, widget.product),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
               PopupMenuItem<String>(
                value: "promo",
                child: ListTile(
                  minLeadingWidth: 10,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.local_offer_rounded),
                  title: Text(AppLocalizations.of(context)!.promotion),
                ),
              ),
              const PopupMenuItem<String>(
                value: edit,
                child: ListTile(
                  minLeadingWidth: 10,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons
                        .edit, // Specify the promotion icon from Material Icons/ Set the color of the icon
                    size: 24, // Set the size of the icon
                  ),
                  title: Text(edit),
                ),
              ),
              const PopupMenuItem<String>(
                value: delete,
                child: ListTile(
                  minLeadingWidth: 10,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.delete_outline),
                  title: Text(delete),
                ),
              ),
            ],
            icon: Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
      body:networkStatus == NetworkStatus.Online
          ? SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

                  Container(
                      color: lightGray,
                      height: 250,
                      width: MediaQuery.of(context).size.width,
                      child:  widget.product.images!.isEmpty
                              ? const FittedBox(
                                  child: Icon(
                                  Icons.restaurant_menu_rounded,
                                  color: gray,
                                ))
                              : Image.memory(
                                  base64.decode(
                                      widget.product.images![widget.product.images!.length-1].data),
                                  fit: BoxFit.cover,
                                )),

            Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: Text(
                  widget.product.productTitle.substring(0, 1).toUpperCase() +
                      widget.product.productTitle.substring(1),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )),
            widget.product.hasActivePromotion!
                ? Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 10),
                    child: Row(
                      children: [
                        Text(
                    "${(widget.product.price *(100- widget.product.percentage!)) / 100} ${AppLocalizations.of(context)!.tunisianDinar}",
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        const Text(
                          "(",
                          style: TextStyle(fontSize: 16, color: gray),
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              "${widget.product.price} ${AppLocalizations.of(context)!.tunisianDinar}",
                              style: TextStyle(fontSize: 16, color: gray),
                              textAlign: TextAlign.center,
                            ),
                            // Horizontal line
                            Positioned(
                              left: 0, // Adjust the position of the line
                              right: 0,
                              child: Container(
                                height: 1,
                                color: gray, // Line color
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          ")",
                          style: TextStyle(fontSize: 16, color: gray),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "- ${widget.product.percentage}%",
                              style: const TextStyle(color: Colors.white),
                            ))
                      ],
                    ),
                  )
                : Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 10),
                    child: Text(
                      "${widget.product.price} ${AppLocalizations.of(context)!.tunisianDinar}",
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    )),
             Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: Text(
                  AppLocalizations.of(context)!
                      .description,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )),
            Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                ),
                child: Text(
                    widget.product.description.substring(0, 1).toUpperCase() +
                        widget.product.description.substring(1)))
          ],
        ),
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
