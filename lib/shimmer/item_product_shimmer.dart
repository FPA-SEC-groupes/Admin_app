import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hello_way/models/product.dart';
import 'package:hello_way/res/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class ItemProductShimmer extends StatelessWidget {
  const ItemProductShimmer({Key? key,}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: gray.withOpacity(0.5),
            highlightColor: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              height: 150,
              width: MediaQuery.of(context).size.width,

            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Shimmer.fromColors(
            baseColor: gray.withOpacity(0.5),
            highlightColor: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              height: 15,
              width: MediaQuery.of(context).size.width / 2,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Shimmer.fromColors(
                baseColor: gray.withOpacity(0.5),
                highlightColor: Colors.white,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  height: 10,
                  width: MediaQuery.of(context).size.width / 5,
                ),
              ),

              Shimmer.fromColors(
                baseColor: gray.withOpacity(0.5),
                highlightColor: Colors.white,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  height: 10,
                  width: MediaQuery.of(context).size.width /8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
