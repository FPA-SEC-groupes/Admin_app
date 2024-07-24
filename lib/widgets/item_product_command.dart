import 'dart:convert';

import 'package:flutter/material.dart';
import '../../utils/const.dart';

import '../res/app_colors.dart';
import '../response/product_with_quantity.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class ItemProductCommand extends StatelessWidget {
  final ProductWithQuantities1 productWithQuantities;
  const ItemProductCommand({Key? key, required this.productWithQuantities}) : super(key: key);

  @override
  Widget build(BuildContext context) {
   // final BasketViewModel _basketViewModel=BasketViewModel();
    double? sum;
    String? formattedPrice;
    if(productWithQuantities.product.hasActivePromotion ?? false)
    {
      sum = (productWithQuantities.product.price * (100 - (productWithQuantities.product.percentage ?? 0))) / 100;
      sum = double.parse(sum.toStringAsFixed(2));
      formattedPrice = "$sum ${AppLocalizations.of(context)!.tunisianDinar}";
    }
    else{
      sum = productWithQuantities.product.price;
      sum= sum = double.parse(sum.toStringAsFixed(2));
      formattedPrice = "$sum ${AppLocalizations.of(context)!.tunisianDinar}";
    }
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
      height: 130,
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          SizedBox(
            height: 120,
            width: 110,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: FittedBox(
                fit: BoxFit.fill,
                child: productWithQuantities.product.images?.length == 0
                    ? Icon(
                  Icons.image_outlined,
                  color: gray.withOpacity(0.5),
                )
                    :Image.network(baseUrl+productUrl+productWithQuantities.product.images![productWithQuantities.product.images!.length-1].fileName)
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            productWithQuantities.product.productTitle.substring(0, 1).toUpperCase() +
                                productWithQuantities.product.productTitle.substring(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10,),
                      Text(
                        formattedPrice!,
                          // "${productWithQuantities.product.price} DT",
                      ),
                      SizedBox(height: 10,),
                  RichText(
                    text: TextSpan(
                      text:"Quantité:",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: (productWithQuantities.quantity-productWithQuantities.oldQuantity).toString(),
                          style: const TextStyle(
                            color: Colors.green,
                          ),
                        ),
                        TextSpan(
                          text: '/${productWithQuantities.quantity}',
                          style: const TextStyle(
                            color:gray,

                          ),
                        ),
                      ],
                    ),),

                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }
}
