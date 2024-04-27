import 'package:draggable_fab/draggable_fab.dart';
import 'package:flutter/material.dart';
import 'package:hello_way/res/app_colors.dart';
import 'package:hello_way/shimmer/item_waiter_shimmer.dart';
import 'package:hello_way/view/add_user.dart';
import 'package:hello_way/view_model/modertors_view_model.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../services/network_service.dart';
import '../../utils/routes.dart';
import '../../utils/secure_storage.dart';
import '../../view_model/profile_view_model.dart';
import '../../widgets/custom_app_bar_with_search.dart';
import '../../widgets/item_moderator.dart';

class ListModerators extends StatefulWidget {
  const ListModerators({Key? key}) : super(key: key);

  @override
  State<ListModerators> createState() => _ListModeratorsState();
}

class _ListModeratorsState extends State<ListModerators> {
  late  ProfileViewModel _profileViewModel;
  final SecureStorage secureStorage = SecureStorage();
  late ModertorsViewModel _modertorsViewModel ;
  bool _isSearching = false;
  String _searchQuery = '';
  @override
  void initState() {

    _modertorsViewModel = ModertorsViewModel(context);
    _profileViewModel = ProfileViewModel(context);
    _fetchModerators();
    super.initState();
  }

  Future<List<User>?> _fetchModerators() async {
    // fetch the list of categories using
    List<User>? moderators = await _modertorsViewModel.getModerators();
    return moderators;
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: orange,
        title: _isSearching
            ? TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.search,
            border: InputBorder.none,
          ),
        )
            : Text(AppLocalizations.of(context)!.listOfSpaceManagers),
        elevation: 1,
        actions: [
          Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  IconButton(
                    icon:  Icon( _isSearching?Icons.close_rounded:Icons.search,),
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                        _searchQuery ='';
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded),
                    onPressed: () async {
                      _profileViewModel.logout().then((_) {
                        secureStorage.deleteAll();

                        Navigator.pushNamed(context, loginRoute);
                      }).catchError((error) {
                      });
                    },
                  ),
                ],
              ))
        ],
      ),
      body: networkStatus == NetworkStatus.Online
          ?FutureBuilder(
          future: _fetchModerators(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView.separated(
                itemCount: 5,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return const ItemWaiterShimmer();
                },
              );
            } else if (snapshot.hasError) {
              return  Center(
                child: Text( AppLocalizations.of(context)!
                        .errorRetrievingData),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return  Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.group_off_rounded,
                        size: 150,
                        color: gray,
                      ),
                      SizedBox(height: 20),
                      Text(
                        AppLocalizations.of(context)!
                            .noManager,
                        style: const TextStyle(fontSize: 22, color: gray),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            } else {
              final List<User> moderators;
              if (_searchQuery.isEmpty) {
                moderators = snapshot.data!;
              } else {
                moderators = (snapshot.data! as List<User>)
                    .where((user) =>
                        user.name!
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()) ||
                        user.lastname!
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()) ||
                        user.email
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()))
                    .toList();
              }
              return ListView.builder(
                  itemCount: moderators.length,
                  itemBuilder: (context, index) {
                    final moderator = moderators[index];

                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: ItemModerator(
                            user: moderator,
                            onDelete: () async {
                              await _modertorsViewModel
                                  .deleteModerator(moderator.id!)
                                  .then((_) async {
                                setState(() {
                                  _fetchModerators();
                                });
                              }).catchError((error) {});
                            },
                          ),
                        ),
                        index != moderators.length - 1
                            ? Container(
                                color: lightGray,
                                height: 10,
                              )
                            : SizedBox()
                      ],
                    );
                  });
            }
          }):Center(
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
              SizedBox(height: 10,),
              MaterialButton(
                color: orange,
                height: 40,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                onPressed:(){
                  setState(() {

                  });
                },


                child: Text(
                  AppLocalizations.of(context)!.retry,
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),

              )
            ],
          ),
        ),
      ),
      floatingActionButton: DraggableFab(
          child: FloatingActionButton(
        onPressed: () async {
          final resultat=await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddUser(
                isModerator: true,
              ),
            ),
          );
          if(resultat!=null && resultat=="User registered successfully!"){

            setState(() {
              _fetchModerators();
            });
          }
        },
        backgroundColor: orange,
        child: const Icon(Icons.person_add),
      )),
    );
  }
}
