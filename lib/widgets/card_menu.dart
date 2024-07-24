import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hello_way/models/product.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hello_way/utils/const.dart';

import '../res/app_colors.dart';

class CardMenu extends StatefulWidget {
  final Product product;
  final void Function()? onTap;
  const CardMenu({Key? key, required this.product, this.onTap}) : super(key: key);

  @override
  _CardMenuState createState() => _CardMenuState();
}

class _CardMenuState extends State<CardMenu> {
  @override
  Widget build(BuildContext context) {
    double? sum;
    String? formattedPrice;
    if(widget.product.hasActivePromotion ?? false)
      {
          sum = (widget.product.price * (100 - (widget.product.percentage ?? 0))) / 100;
          sum = double.parse(sum.toStringAsFixed(2));
           formattedPrice = "$sum ${AppLocalizations.of(context)!.tunisianDinar}";
      }
      else{
        sum = widget.product.price;
        sum= sum = double.parse(sum.toStringAsFixed(2));
    }
    return Card(
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all(10),
        width: (MediaQuery.of(context).size.width / 2) - 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              width: MediaQuery.of(context).size.width,
              child: FittedBox(
                fit: BoxFit.fill,
                child: (widget.product.images?.isEmpty ?? true)
                    ? Icon(
                  Icons.image_outlined,
                  color: Colors.grey.withOpacity(0.5),
                )
                    : Image.network(
                  baseUrl + productUrl + (widget.product.images!.last.fileName ?? ''),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: Text(
                (widget.product.productTitle?.isNotEmpty ?? false)
                    ? widget.product.productTitle.substring(0, 1).toUpperCase() +
                    widget.product.productTitle.substring(1)
                    : '',
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis, // Display ellipsis when text overflows
                maxLines: 2,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.product.hasActivePromotion ?? false)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                              formattedPrice!,
                            // "${(widget.product.price * (100 - (widget.product.percentage ?? 0))) / 100} DT",
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(width: 5),
                          // const Text(
                          //   "(",
                          //   style: TextStyle(color: gray),
                          // ),
                          // Stack(
                          //   alignment: Alignment.center,
                          //   children: [
                          //     Text(
                          //       "${widget.product.price} DT",
                          //       style: const TextStyle(color: gray),
                          //       textAlign: TextAlign.center,
                          //     ),
                          //     Positioned(
                          //       left: 0,
                          //       right: 0,
                          //       child: Container(
                          //         height: 1,
                          //         color: gray,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // const Text(
                          //   ")",
                          //   style: TextStyle(color: gray),
                          // ),
                        ],
                      ),
                      // if(widget.product.hasActivePromotion!)
                      // Container(
                      //   padding: const EdgeInsets.all(5),
                      //   decoration: BoxDecoration(
                      //     color: Colors.orange.withOpacity(0.5),
                      //     borderRadius: BorderRadius.circular(8),
                      //   ),
                      //   child: Text(
                      //     "- ${widget.product.percentage}%",
                      //     style: const TextStyle(color: Colors.white),
                      //   ),
                      // )else
                      //   Text(""),
                      Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "- ${widget.product.percentage}%",
                            style: const TextStyle(color: Colors.white),
                          ))
                    ],
                  )
                else
                  Text(
                    "${sum} ${AppLocalizations.of(context)!.tunisianDinar}",
                  ),
                GestureDetector(
                  onTap: widget.onTap,
                  child:
                  // widget.product.hasActivePromotion ?? false
                  //     ?
                  // Container(
                  //   padding: const EdgeInsets.all(5),
                  //   decoration: BoxDecoration(
                  //     color: Colors.orange,
                  //     borderRadius: BorderRadius.circular(8),
                  //   ),
                  //   child: Text(
                  //     "- ${widget.product.percentage ?? 0}%",
                  //     style: const TextStyle(color: Colors.white),
                  //   ),
                  // )
                  //     :
                  const Icon(
                    Icons.local_offer_rounded,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
