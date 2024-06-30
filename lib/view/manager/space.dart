import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hello_way/utils/const.dart';
import 'package:hello_way/utils/secure_storage.dart';
import 'package:hello_way/view/manager/updateSpace.dart';
import 'package:hello_way/view_model/modertors_view_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/space.dart';
import '../../res/app_colors.dart';
import '../../services/network_service.dart';
import '../../shimmer/space_details_shimmer.dart';
import '../../utils/routes.dart';
import '../../view_model/space_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DetailsSpace extends StatefulWidget {
  @override
  _DetailsSpaceState createState() => _DetailsSpaceState();
}

class _DetailsSpaceState extends State<DetailsSpace> {
  late final SpaceViewModel _spaceViewModel;
  final PageController _pageController = PageController();
  final SecureStorage secureStorage = SecureStorage();
  late final ModertorsViewModel _modertorsViewModel;
  int _currentPage = 0;
  Space? space;
  List<Widget> _pages = [];
  Timer? _timer;
  DateTime currentDate = DateTime.now();
  int? id;
  int? percentage;

  @override
  void initState() {
    super.initState();
    _spaceViewModel = SpaceViewModel(context);
    _modertorsViewModel = ModertorsViewModel(context);

    getManagerSumCommandsPerMonth();
    fetchSpaceById();
  }

  @override
  void dispose() {
    _pageController.dispose();
    stopTimer(); // Cancel the timer
    super.dispose();
  }

  Future<Space> fetchSpaceById() async {
    String? idUser = await secureStorage.readData(authentifiedUserId);
    String? percentageUser = await secureStorage.readData(UserPercentage);
    setState(() {
      id = int.parse(idUser!);
      percentage=int.parse(percentageUser!);
    });
    Space _space = await _spaceViewModel.getSpaceById();
    setState(() {
      _pages = _space.images!.isEmpty
          ? [
        const FittedBox(
          child: Icon(Icons.image_outlined, color: gray),
        )
      ]
          : List.generate(
        _space.images!.length,
            (index) => SizedBox(
          height: 50,
          child: ClipRRect(
            child: FittedBox(
              fit: BoxFit.fill,
              child: Image.network(baseUrl+spaceUrl+_space!.images![index].fileName)
              // Image.memory(
              //   base64.decode(_space.images![index].data),
              // ),
            ),
          ),
        ),
      );
    });

    space = _space;
    startTimer();
    return _space;
  }
  Future<double> getManagerSumCommandsPerMonth() async {
    String formattedDate = DateFormat('yyyy-MM').format(currentDate);
    double sum = await  _modertorsViewModel.getManagerSumCommandsPerMonth(
        id as int, formattedDate);
    return sum;
  }
  void startTimer() {
    if (_pages.length <= 1) {
      return; // Exit the method if there's only one page
    }
    _timer = Timer.periodic(Duration(seconds: 10), (Timer timer) {
      if (_pageController.hasClients) {
        if (_currentPage < _pages.length - 1) {
          _pageController.animateToPage(
            _currentPage + 1,
            duration: Duration(seconds: 1),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.jumpToPage(
            0,
          );
        }
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    //final space = ModalRoute.of(context)!.settings.arguments as Space;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.mySpace),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateSpace(
                    space: space!,
                  ),
                ),
              ).then((value) {
                setState(() {
                  fetchSpaceById();
                });
              });
            },
          ),
        ],
      ),
      body: networkStatus == NetworkStatus.Online
          ? space != null
          ? SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: screenHeight / 3,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: _pages,
                  ),
                ),
                Positioned(
                  left: 10,
                  bottom: 10,
                  right: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List<Widget>.generate(_pages.length, (int index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 10,
                        width: (index == _currentPage) ? 30 : 10,
                        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: (index == _currentPage) ? orange : Colors.grey,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Text(
                space!.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: space!.rating != null
                  ? Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: yellow,
                    size: 16,
                  ),
                  Text(
                    "${space!.rating}/5 ",
                  ),
                  Text(
                    "(${space!.numberOfRatings})",
                    style: const TextStyle(color: gray),
                  ),
                ],
              )
                  : Text(
                AppLocalizations.of(context)!.noRating,
                style: const TextStyle(color: gray),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Text(
                space!.validation ?? 'Default validation text', // Provide a default value
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: orange,
                        borderRadius: BorderRadius.circular(10), // Set the radius here
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.phone,
                            color: Colors.white,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            space!.phoneNumber.toString(),
                            style: const TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: orange,
                        borderRadius: BorderRadius.circular(10), // Set the radius here
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.pages_rounded,
                            color: Colors.white,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            "${space!.surfaceEnM2} m²",
                            style: const TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: orange,
                      borderRadius: BorderRadius.circular(10), // Set the radius here
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, spaceLocationRoute, arguments: space);
                      },
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Text(
                AppLocalizations.of(context)!.about,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Text(space!.description),
            ),
            // Show list of WiFi information if validation is "wifi"
            if (space!.validation == "wifi" && space!.wifis != null && space!.wifis!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "WiFi Information",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...space!.wifis!.map((wifi) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Column(
                          children: [
                            Text(
                              "SSID: ${wifi.ssid}",
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Password: ${wifi.password}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            Padding(padding: EdgeInsetsDirectional.all(10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: orange, // Or any color you want
                borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text("${AppLocalizations.of(context)!.on} ${DateFormat('dd-MM-yyyy').format(currentDate)}",style: const TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),),
                  const SizedBox(height: 10,),
                  Row(
                    children: [
                      Expanded(
                        child: FutureBuilder<double>(
                          future: getManagerSumCommandsPerMonth(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            } else {
                              double sum = snapshot.data!;
                              double sum1 = double.parse((sum - (sum / (1 + percentage! / 100))).toStringAsFixed(2));
                              double sum2 = double.parse((sum-sum1).toStringAsFixed(2));
                              return
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.forYou,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SvgPicture.asset('assets/images/coin.svg',
                                            height: 60, width: 60, color: Colors.white),
                                        Text('$sum2 ${AppLocalizations.of(context)!.tunisianDinar}',style: const TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),),
                                      ],
                                    ),
                                      SizedBox(width: 50,),
                                      Column(
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!.forAdmin,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SvgPicture.asset('assets/images/coin.svg',
                                              height: 60, width: 60, color: Colors.white),
                                          Text('$sum1 ${AppLocalizations.of(context)!.tunisianDinar}',style: const TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),),
                                        ],
                                      )
                                  ]
                                );
                            }
                          },
                        ),
                      ),
                      // Expanded(
                      //   child:FutureBuilder<int>(
                      //     future: getServerCommandsCountPerDay(widget.modertors.id),
                      //     builder: (context, snapshot) {
                      //       if (snapshot.connectionState ==
                      //           ConnectionState.waiting) {
                      //         return const Center(
                      //           child: CircularProgressIndicator(),
                      //         );
                      //       } else if (snapshot.hasError) {
                      //         return Center(
                      //           child: Text('Error: ${snapshot.error}'),
                      //         );
                      //       } else {
                      //         int nbOrders = snapshot.data!;
                      //         return Column(
                      //           children: [
                      //             const Icon(
                      //               Icons.file_copy,
                      //               size: 50,
                      //               color: Colors.white,
                      //             ),
                      //             Text('$nbOrders ${AppLocalizations.of(context)!.orders}',style: const TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),),
                      //           ],
                      //         );
                      //       }
                      //     },
                      //   ),)
                    ],
                  ),
                ],
              ),
            ),)
          ],
        ),
      )
          : const SpaceDetailsShimmer()
          : Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.network_check,
                size: 150,
                color: gray,
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.noInternet,
                style: const TextStyle(fontSize: 22, color: gray),
                textAlign: TextAlign.center,
              ),
              Text(
                AppLocalizations.of(context)!.checkYourInternet,
                style: const TextStyle(fontSize: 22, color: gray),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              MaterialButton(
                color: orange,
                height: 40,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                onPressed: () {
                  setState(() {});
                },
                child: Text(
                  AppLocalizations.of(context)!.retry,
                  style: const TextStyle(
                      fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
