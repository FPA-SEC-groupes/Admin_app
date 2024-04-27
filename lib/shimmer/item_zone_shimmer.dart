import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../res/app_colors.dart';

class ItemZoneShimmer extends StatelessWidget {
  const ItemZoneShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
       padding: const EdgeInsets.only(left: 20),

        color: Colors.white,
        height: 70,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Shimmer.fromColors(
              baseColor: gray.withOpacity(0.5),
              highlightColor: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                height: 15,
                width: MediaQuery.of(context).size.width /3,
              ),
            ),
          ],
        ),);
  }
}
