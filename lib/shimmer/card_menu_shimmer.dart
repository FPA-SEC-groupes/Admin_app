import 'package:flutter/material.dart';
import 'package:hello_way/res/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class CardMenuShimmer extends StatelessWidget {
  const CardMenuShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return   Card(
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.all(10),
        width: (MediaQuery.of(context).size.width / 2) - 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Shimmer.fromColors(
              baseColor: gray.withOpacity(0.5),
              highlightColor: Colors.white,
              child: Container(
                height: 120,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              child: Shimmer.fromColors(
                baseColor: gray.withOpacity(0.5),
                highlightColor: Colors.white,
                child: Container(
                  height: 15,
                  width: MediaQuery.of(context).size.width / 2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            Shimmer.fromColors(
              baseColor: gray.withOpacity(0.5),
              highlightColor: Colors.white,
              child: Container(
                height: 15,
                width: MediaQuery.of(context).size.width / 4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
