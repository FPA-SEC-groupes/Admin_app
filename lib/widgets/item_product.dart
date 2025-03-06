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
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reduced image size for better display
          Container(
            width: 80, // Adjusted for better fit
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200,
            ),
            child: widget.product.images!.isEmpty
                ? Icon(Icons.image_outlined, color: gray.withOpacity(0.5))
                : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                baseUrl + productUrl + widget.product.images!.last.fileName,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            ),
          ),

          const SizedBox(width: 10), // Spacing between image and text

          // Expanded to ensure text and details fit properly
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.productTitle[0].toUpperCase() +
                      widget.product.productTitle.substring(1),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis, // Prevents text overflow
                  maxLines: 1, // Limits text to one line
                ),
                const SizedBox(height: 5),

                // Price & Discount Section
                widget.product.hasActivePromotion!
                    ? Row(
                  children: [
                    Text(
                      "${(widget.product.price * (100 - widget.product.percentage!)) / 100} ${AppLocalizations.of(context)!.tunisianDinar}",
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "(${widget.product.price} ${AppLocalizations.of(context)!.tunisianDinar})",
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "-${widget.product.percentage}%",
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    )
                  ],
                )
                    : Text(
                  "${widget.product.price} ${AppLocalizations.of(context)!.tunisianDinar}",
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),

                const SizedBox(height: 5),

                // Availability Checkbox
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
                          await _updateProductViewModel.updateProduct(
                              widget.product, widget.product.idProduct!);
                        },
                      ),
                    ),
                    const SizedBox(width: 5), // Added padding between checkbox and text
                    Text(AppLocalizations.of(context)!.outOfStock),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
