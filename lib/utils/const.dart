import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
//const baseUrl="https://full-bell-production.up.railway.app";

const baseUrl = "http://192.168.1.118:8082";
const categoryId = "CategoryId";
const authentifiedUserId = "AuthentifiedUserId";
const roleKey = "Role";
const spaceIdKey = "spaceId";
const roleManager = "ROLE_PROVIDER";
const roleWaiter = "ROLE_WAITER";
const roleAdmin = "ROLE_ADMIN";
const basketIdKey = "BasketId";
const nbNewNotifications="nbNewNotifications";
const email="email";

const showMore = "showMore";
const add = "add";
const edit = "edit";
const delete = "delete";
const downloadQrCode = "downloadQrCode";

List<String> initListUnits(BuildContext context) {
  return [
    AppLocalizations.of(context)!.kilogram,
    AppLocalizations.of(context)!.liter,
    AppLocalizations.of(context)!.piece
  ];
}

List<Map<String, String>> initListCategories(BuildContext context) {
  return [
    {AppLocalizations.of(context)!.coffeeShop: 'Café'},
    {AppLocalizations.of(context)!.restaurant: 'Restaurant'},
    {AppLocalizations.of(context)!.bar: 'Bar'},
  ];
}

List<String> initListOrdersStatus(BuildContext context) {
  return [
    AppLocalizations.of(context)!.all,
    AppLocalizations.of(context)!.pendingStatus,
    AppLocalizations.of(context)!.confirmedStatus
  ];
}
