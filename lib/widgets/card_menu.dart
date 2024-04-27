import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hello_way/models/product.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
                child: widget.product.images!.isEmpty
                    ? Icon(
                        Icons.image_outlined,
                        color: Colors.grey.withOpacity(0.5),
                      )
                    : Image.memory(
                        base64.decode(widget.product.images![widget.product.images!.length-1].data)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: Text(
                widget.product.productTitle.substring(0, 1).toUpperCase() +
                    widget.product.productTitle.substring(1),
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis, // Display ellipsis when text overflows
                maxLines: 2,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${widget.product.price} ${AppLocalizations.of(context)!.tunisianDinar}"),
                GestureDetector(
                  onTap: widget.onTap,
                  child: widget.product.hasActivePromotion!
                      ? Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "- ${widget.product.percentage}%",
                            style: const TextStyle(color: Colors.white),
                          ))
                      : const Icon(
                          Icons.local_offer_rounded,
                          color: Colors.orange,
                        ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
