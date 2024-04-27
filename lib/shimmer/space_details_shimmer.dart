import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../res/app_colors.dart';

class SpaceDetailsShimmer extends StatelessWidget {
  const SpaceDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
            children: [
              Shimmer.fromColors(
                baseColor: gray.withOpacity(0.5),
                highlightColor: Colors.white,
                child: Container(
                  height:screenHeight / 3,
                  color: Colors.white,
                ),
              ),
              Positioned(
                left: 0,
                bottom: 10,
                right: 0,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 10,
                        width: 30,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        height: 10,
                        width: 10,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
                        ),
                      )
                    ]),
              ),
            ]),
        Shimmer.fromColors(
          baseColor: gray.withOpacity(0.5),
          highlightColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Container(
              height: 15,
              width: MediaQuery.of(context).size.width/3,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5,),
        Shimmer.fromColors(
          baseColor: gray.withOpacity(0.5),
          highlightColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20,),
            child: Container(
              height: 10,
              width: MediaQuery.of(context).size.width/4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Row(
              children: [
                Expanded(
                    child: Shimmer.fromColors(
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
                    )),
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Shimmer.fromColors(
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
                ),
                const SizedBox(
                  width: 5,
                ),
                Shimmer.fromColors(
                  baseColor: gray.withOpacity(0.5),
                  highlightColor: Colors.white,
                  child: Container(
                    height: 30,

                    width: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )
              ],
            )),

        Shimmer.fromColors(
          baseColor: gray.withOpacity(0.5),
          highlightColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Container(
              height: 15,
              width: MediaQuery.of(context).size.width/4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10,),
        Shimmer.fromColors(
          baseColor: gray.withOpacity(0.5),
          highlightColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Container(
              height: 10,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5,),
        Shimmer.fromColors(
          baseColor: gray.withOpacity(0.5),
          highlightColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Container(
              height: 10,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5,),
        Shimmer.fromColors(
          baseColor: gray.withOpacity(0.5),
          highlightColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Container(
              height: 10,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
