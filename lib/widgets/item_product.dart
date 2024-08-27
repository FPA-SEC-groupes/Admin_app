import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hello_way/models/product.dart';
import 'package:hello_way/res/app_colors.dart';
import 'package:hello_way/utils/const.dart';
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
    _updateProductViewModel = ProductsViewModel(context);
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
            height: 120, // Reduced image height for better fit
            width: MediaQuery.of(context).size.width,
            child: FittedBox(
              fit: BoxFit.cover, // Adjust the image fit
              child: widget.product.images!.isEmpty
                  ? Icon(Icons.image_outlined, color: gray.withOpacity(0.5))
                  : Image.network(baseUrl + productUrl + widget.product.images![widget.product.images!.length - 1].fileName),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(
              widget.product.productTitle.substring(0, 1).toUpperCase() +
                  widget.product.productTitle.substring(1),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          widget.product.hasActivePromotion!
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "${(widget.product.price * (100 - widget.product.percentage!)) / 100} ${AppLocalizations.of(context)!.tunisianDinar}",
                  ),
                  const SizedBox(width: 5),
                  const Text("(", style: TextStyle(fontSize: 16, color: gray)),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        "${widget.product.price} ${AppLocalizations.of(context)!.tunisianDinar}",
                        style: TextStyle(fontSize: 16, color: gray, decoration: TextDecoration.lineThrough), // Strike-through text
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const Text(")", style: TextStyle(fontSize: 16, color: gray)),
                  const SizedBox(width: 20),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "-${widget.product.percentage}%",
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Row(
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: Checkbox(
                        activeColor: orange,
                        checkColor: Colors.white,
                        value: !widget.product.available,
                        onChanged: (bool? newValue) async {
                          setState(() {
                            widget.product.available = !newValue!;
                          });
                          await _updateProductViewModel.updateProduct(widget.product, widget.product.idProduct!);
                        },
                      ),
                    ),
                    const SizedBox(width: 5), // Added padding between checkbox and text
                    Text(AppLocalizations.of(context)!.outOfStock),
                  ],
                ),
              ),
            ],
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${widget.product.price} ${AppLocalizations.of(context)!.tunisianDinar}"),
              Row(
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: Checkbox(
                      activeColor: orange,
                      checkColor: Colors.white,
                      value: !widget.product.available,
                      onChanged: (bool? newValue) async {
                        setState(() {
                          widget.product.available = !newValue!;
                        });
                        await _updateProductViewModel.updateProduct(widget.product, widget.product.idProduct!);
                      },
                    ),
                  ),
                  const SizedBox(width: 5), // Added padding between checkbox and text
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
