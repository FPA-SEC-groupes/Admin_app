import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../res/app_colors.dart';

class ItemCommandShimmer extends StatelessWidget {
  const ItemCommandShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10),
        child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: gray.withOpacity(0.5),
                      highlightColor: Colors.white,
                      child: Container(
                        height: 15,
                        width: MediaQuery.of(context).size.width/1.5,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Shimmer.fromColors(
                      baseColor: gray.withOpacity(0.5),
                      highlightColor: Colors.white,
                      child: Container(
                        height: 10,
                        width:  MediaQuery.of(context).size.width / 5,
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
