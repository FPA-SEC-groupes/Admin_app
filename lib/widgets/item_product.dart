import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hello_way/models/product.dart';
import 'package:hello_way/res/app_colors.dart';

import '../view_model/products_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class ItemProduct extends StatefulWidget {
  final Product product;

  const ItemProduct({Key? key, required this.product}) : super(key: key);

  @override
  _ItemProductState createState() => _ItemProductState();
}

class _ItemProductState extends State<ItemProduct> {
  late ProductsViewModel _updateProductViewModel;
  @override
  void initState() {
    _updateProductViewModel=ProductsViewModel(context);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 150,
            width: MediaQuery.of(context).size.width,
            child: FittedBox(
              fit: BoxFit.fill,
              child: widget.product.images!.isEmpty
                  ? Icon(Icons.image_outlined, color: gray.withOpacity(0.5))
                  : Image.memory(base64.decode(widget.product.images![widget.product.images!.length-1].data)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 5),
            child: Text(
              widget.product.productTitle.substring(0, 1).toUpperCase() +
                  widget.product.productTitle.substring(1),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              overflow: TextOverflow.ellipsis, // Display ellipsis when text overflows
              maxLines: 1,
            ),
          ),
          widget.product.hasActivePromotion!
              ? Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "${(widget.product.price *(100- widget.product.percentage!)) / 100} ${AppLocalizations.of(context)!.tunisianDinar}",

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
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          activeColor: orange,
                          checkColor: Colors.white,
                          value: !widget.product.available,
                          onChanged: (bool? newValue) async {
                            setState(() {
                              widget.product.available = !newValue!;
                            });
                            await _updateProductViewModel.updateProduct( widget.product,widget.product.idProduct!);
                          },
                        ),
                      ),
                      Text(AppLocalizations.of(context)!.outOfStock),
                    ],
                  ),
                ],
              )

              : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${widget.product.price} ${AppLocalizations.of(context)!.tunisianDinar}",

                  ),
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          activeColor: orange,
                          checkColor: Colors.white,
                          value: !widget.product.available,
                          onChanged: (bool? newValue) async {
                            setState(() {
                              widget.product.available = !newValue!;
                            });
                            await _updateProductViewModel.updateProduct( widget.product,widget.product.idProduct!);
                          },
                        ),
                      ),
                      Text(AppLocalizations.of(context)!.outOfStock),
                    ],
                  ),
                ],
              ),
        ],
      ),
    );
  }
}
