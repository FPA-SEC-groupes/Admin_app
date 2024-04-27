import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../res/app_colors.dart';

class ItemWaiterShimmer extends StatelessWidget {
  const ItemWaiterShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      height: 170,
      child: Row(
        children: [
          Stack(
            children: [
              Shimmer.fromColors(
                baseColor: gray.withOpacity(0.5),
                highlightColor: Colors.white,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                ),
              ),
            ],
          ),

          //Image.network("http://10.0.2.2:9090/img/${game.url}", width: 200, height: 94),

          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: const Align(
                    alignment: Alignment.topRight,
                    child: Icon(
                      Icons.more_vert_rounded,
                      color: gray,
                    )),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                  padding: EdgeInsets.only(left: 10, bottom: 10),
                  child: Shimmer.fromColors(
                      baseColor: gray.withOpacity(0.5),
                      highlightColor: Colors.white,
                      child: Container(
                        height: 15,
                        width: MediaQuery.of(context).size.width / 3,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ))),
              Padding(
                  padding: EdgeInsets.only(left: 10, bottom: 10),
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
                      ))),
            ],
          ))
        ],
      ),
    );
  }
}
