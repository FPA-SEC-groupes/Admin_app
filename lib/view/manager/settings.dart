
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hello_way/res/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/l10n.dart';
import '../../services/network_service.dart';
import '../../utils/routes.dart';
import '../../utils/secure_storage.dart';
import '../../view_model/language_provider.dart';
import '../../view_model/profile_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late  ProfileViewModel _profileViewModel;
  final SecureStorage secureStorage = SecureStorage();





  void launchEmail() async {
    final email = "recipient@example.com"; // Replace with the recipient's email address

    final uri = Uri(
      scheme: "mailto",
      path: email,
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Impossible de lancer l\'email';
    }
  }







  @override
  void initState() {
    _profileViewModel = ProfileViewModel(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
        backgroundColor: lightGray,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: orange,
          title: Text(
            AppLocalizations.of(context)!.settings,
          ),
          elevation: 0,
        ),
        body:networkStatus == NetworkStatus.Online
            ? SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              AppLocalizations.of(context)!.myAccount,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 5, bottom: 5),
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  trailing: const Icon(Icons.navigate_next_rounded),
                  visualDensity: const VisualDensity(vertical: 0.0),
                  dense: true,
                  title:  Text( AppLocalizations.of(context)!.profile, style: const TextStyle(fontSize: 16)),
                  onTap: () async {
                    Navigator.pushNamed(context, profileRoute);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.lock_reset_outlined),
                  trailing: const Icon(Icons.navigate_next_rounded),
                  visualDensity: const VisualDensity(vertical: 0.0),
                  dense: true,
                  title: Text( AppLocalizations.of(context)!.changePassword,
                      style: const TextStyle(fontSize: 16)),
                  onTap: () async {
                    Navigator.pushNamed(context, changePasswordRoute);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout_rounded),
                  visualDensity: const VisualDensity(vertical: 0.0),
                  dense: true,
                  title:  Text(
                    AppLocalizations.of(context)!.disconnection,
                    style: const TextStyle(fontSize: 16),
                  ),
                  onTap: () async {
                    _profileViewModel.logout().then((_) {
                      secureStorage.deleteAll();

                      Navigator.pushNamed(context, loginRoute);
                    }).catchError((error) {
                    });
                  },
                ),
              ],
            ),
          ),
           Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              AppLocalizations.of(context)!.mySpace,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 5, bottom: 5),
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Column(
              children: [
                ListTile(
                  leading: SvgPicture.asset('assets/images/shop-icon.svg',
                      height: 23, width: 24, color: Colors.grey),
                  trailing: const Icon(Icons.navigate_next_rounded),
                  visualDensity: const VisualDensity(vertical: 0.0),
                  dense: true,
                  title:
                      Text( AppLocalizations.of(context)!.mySpace, style: const TextStyle(fontSize: 16)),
                  onTap: () async {
                    Navigator.pushNamed(context, detailsSpaceRoute);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.group_work_rounded),
                  trailing: const Icon(Icons.navigate_next_rounded),
                  visualDensity: const VisualDensity(vertical: 0.0),
                  dense: true,
                  title:
                      Text( AppLocalizations.of(context)!.myZones, style: const TextStyle(fontSize: 16)),
                  onTap: () async {
                    Navigator.pushNamed(context, listZonesRoute);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.shopping_bag_rounded),
                  trailing: const Icon(Icons.navigate_next_rounded),
                  visualDensity: const VisualDensity(vertical: 0.0),
                  dense: true,
                  title:
                      Text( AppLocalizations.of(context)!.myStock, style: const TextStyle(fontSize: 16)),
                  onTap: () async {
                    Navigator.pushNamed(context, stockRoute);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.event),
                  trailing: const Icon(Icons.navigate_next_rounded),
                  visualDensity: const VisualDensity(vertical: 0.0),
                  dense: true,
                  title: Text( AppLocalizations.of(context)!.myEvents,
                      style: const TextStyle(fontSize: 16)),
                  onTap: () async {
                    Navigator.pushNamed(context, calendarEventsRoute);
                  },
                ),
              ],
            ),
          ),
           Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              AppLocalizations.of(context)!.general,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 5, bottom: 5),
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language_rounded),
                  trailing: const Icon(Icons.navigate_next_rounded),
                  visualDensity: const VisualDensity(vertical: 0.0),
                  dense: true,
                  title:  Text(
                    AppLocalizations.of(context)!.language,
                    style: const TextStyle(fontSize: 16),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text( AppLocalizations.of(context)!.language),
                          content: StatefulBuilder(
                            builder: (context, setState) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: L10n.all.map((locale) {
                                  int index = languageProvider
                                      .getCurrentLanguageIndex();
                                  bool isSelected = locale == L10n.all[index];
                                  return RadioListTile(
                                    title:
                                        Text(locale.languageCode.toUpperCase()),
                                    value: locale,
                                    groupValue:
                                        isSelected ? L10n.all[index] : null,
                                    onChanged: (value) {
                                      languageProvider.changeLocale(value!);
                                      Navigator.pop(context);
                                    },
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.message),
                  trailing: const Icon(Icons.navigate_next_rounded),
                  dense: true,
                  title: Text(
                    AppLocalizations.of(context)!.contactUs,
                    style: const TextStyle(fontSize: 16),
                  ),
                  onTap: () {
                    launchEmail();
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info_sharp),
                  trailing: const Icon(Icons.navigate_next_rounded),
                  visualDensity: const VisualDensity(vertical: 0.0),
                  dense: true,
                  title:  Text(
                    AppLocalizations.of(context)!.aboutUs,
                    style: const TextStyle(fontSize: 16),
                  ),
                  onTap: () {
                    //    Navigator.pushNamed(context, signUpRoute);
                  },
                ),
              ],
            ),
          )
        ])):Center(
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
        ),);
  }
}
