import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../res/app_colors.dart';

class ItemReservationShimmer extends StatelessWidget {
  const ItemReservationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Shimmer.fromColors(
                baseColor: gray.withOpacity(0.5),
                highlightColor: Colors.white,
                child: Container(
                  height: 15,
                  width: MediaQuery.of(context).size.width/2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              Shimmer.fromColors(
                baseColor: gray.withOpacity(0.5),
                highlightColor: Colors.white,
                child: Container(
                  height: 30,
                  width: MediaQuery.of(context).size.width/4,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Shimmer.fromColors(
            baseColor: gray.withOpacity(0.5),
            highlightColor: Colors.white,
            child: Container(
              height: 10,
              width:  MediaQuery.of(context).size.width / 3,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 10,),
          Shimmer.fromColors(
            baseColor: gray.withOpacity(0.5),
            highlightColor: Colors.white,
            child: Container(
              height: 10,
              width:  MediaQuery.of(context).size.width / 2,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
