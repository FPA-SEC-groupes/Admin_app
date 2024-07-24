import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:hello_way/models/product.dart';
import 'package:hello_way/view_model/products_view_model.dart';
import 'package:hello_way/widgets/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
import '../../res/app_colors.dart';
import '../../services/network_service.dart';
import '../../utils/const.dart';
import '../../utils/secure_storage.dart';
import '../../view_model/gallery_permission_view_model.dart';
import '../../widgets/button.dart';
import '../../widgets/input_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddProduct extends StatefulWidget {
  final Product? product;
  const AddProduct({Key? key, this.product}) : super(key: key);

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final SecureStorage secureStorage = SecureStorage();
  late ProductsViewModel _addProductViewModel;
  final GalleryViewModel _galleryViewModel = GalleryViewModel();
  final GlobalKey<FormState> _addProductFormKey = GlobalKey<FormState>();
  late final TextEditingController _titleProductController,
      _priceProductController,
      _descriptionController;
  String? errorText;
  bool _submitted = false ;
  @override
  void initState() {
    super.initState();
    _addProductViewModel = ProductsViewModel(context);
    _titleProductController = TextEditingController();
    _priceProductController = TextEditingController();
    _descriptionController = TextEditingController();
    if (widget.product != null) {
      _titleProductController.text = widget.product!.productTitle;
      _priceProductController.text = widget.product!.price.toString();
      _descriptionController.text = widget.product!.description;
    }

    _titleProductController.addListener(() {
      setState(() {
        errorText = null; // Clear error text when title changes
        if (_submitted) {
          _addProductFormKey.currentState?.validate();
        }
      });
    });
    _priceProductController.addListener(() {
      if (_submitted) {
        setState(() {
          _addProductFormKey.currentState?.validate();
        });
      }
    });
    _descriptionController.addListener(() {
      if (_submitted) {
        setState(() {
          _addProductFormKey.currentState?.validate();
        });
      }
    });
  }

  @override
  void dispose() {
    _titleProductController.dispose();
    _priceProductController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _addProductFormKey.currentState?.validate();
    });
  }

  // String? _validationTitle(String? value) {
  //   if (value == null || value.isEmpty) {
  //     return AppLocalizations.of(context)!.inputRequiredError;
  //   } else if (errorText != null) {
  //     return errorText;
  //   }
  //   return null;
  // }
  String? _validationTitle(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.inputRequiredError;
    }
    // Pattern to allow all letters, specific characters, spaces, and underscores
    final pattern = RegExp(r'^[\w\sàâäéèêëîïôöùûüçÀÂÄÉÈÊËÎÏÔÖÙÛÜÇ_ :\-]+$', caseSensitive: false);
    if (!pattern.hasMatch(value)) {
      return 'Only letters, specific characters, spaces, and underscores are allowed.';
    }
    return null;
  }
  Future<void> _uploadImage(File image, int productId) async {
    try {
      await _addProductViewModel.uploadImage(image, productId);
      print('Image uploaded successfully');
    } catch (e) {
      print('Error uploading image: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: Toolbar(
        title: widget.product == null
            ? AppLocalizations.of(context)!.newProduct
            : _titleProductController.text,
      ),
      body: networkStatus == NetworkStatus.Online
          ? Form(
        key: _addProductFormKey,
        child: GestureDetector(
          onTap: () {
            final FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                MultiProvider(
                  providers: [
                    ChangeNotifierProvider(
                        create: (_) => _galleryViewModel),
                  ],
                  child: Consumer<GalleryViewModel>(
                    builder: (context, galleryViewModel, _) => Stack(
                      children: <Widget>[
                        Container(
                            color: lightGray,
                            height: 250,
                            width: MediaQuery.of(context).size.width,
                            child: galleryViewModel.image != null
                                ? Image.file(
                              galleryViewModel.image!,
                              fit: BoxFit.cover,
                            )
                                : widget.product != null
                                ? widget.product!.images!.isEmpty
                                ? const FittedBox(
                                child: Icon(
                                  Icons.restaurant_menu_rounded,
                                  color: gray,
                                ))
                                : Image.network(baseUrl +
                                productUrl +
                                widget.product!.images![
                                widget.product!
                                    .images!
                                    .length -
                                    1]
                                    .fileName)
                                : const FittedBox(
                                child: Icon(
                                  Icons.restaurant_menu_rounded,
                                  color: gray,
                                ))),
                        Positioned(
                          right: 10,
                          bottom: 10,
                          child: ElevatedButton(
                            onPressed: () async {
                              bool isGranted = await galleryViewModel
                                  .requestGalleryPermission(context);
                              if (isGranted) {
                                await galleryViewModel.selectImage();
                                print(_galleryViewModel.image!);
                              } else {
                                // Do something when permission is not granted
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              fixedSize: const Size(45, 45),
                              shape: const CircleBorder(),
                            ),
                            child: Icon(
                              widget.product != null
                                  ? Icons.edit
                                  : Icons.add,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      InputForm(
                          hint: AppLocalizations.of(context)!.title,
                          controller: _titleProductController,
                          validator: _validationTitle,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      InputForm(
                        hint: AppLocalizations.of(context)!.price,
                        keyboardType: TextInputType.number,
                        controller: _priceProductController,
                        validator: MultiValidator([
                          RequiredValidator(
                            errorText: AppLocalizations.of(context)!.inputRequiredError,
                          ),
                          // PatternValidator(r'^[^.,]*$', errorText: AppLocalizations.of(context)!.dotsOrcommasError), // No dots or commas
                          PatternValidator(
                            r'^\d+',
                            errorText: AppLocalizations.of(context)!.nigativeError,
                          ), //Valid integer pattern
                        ]),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      InputForm(
                        maxLines: 5,
                        hint: AppLocalizations.of(context)!.description,
                        controller: _descriptionController,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Button(
                        text: widget.product == null
                            ? AppLocalizations.of(context)!.add
                            : AppLocalizations.of(context)!.modify,
                        onPressed: () async {
                          setState(() {
                            _submitted=true;
                          });
                          if (_addProductFormKey.currentState!
                              .validate()) {
                            _addProductFormKey.currentState!.save();

                            if (widget.product == null) {
                              final _selectedCategoryId =
                              await secureStorage.readData(categoryId);
                              Product product = Product(
                                  productTitle:
                                  _titleProductController.text.trim(),
                                  price: double.parse(
                                      _priceProductController.text.contains(',')? _priceProductController.text.replaceAll(',', '.'): _priceProductController.text),
                                  description:
                                  _descriptionController.text.trim(),
                                  available: true);
                              await _addProductViewModel
                                  .addProductByIdCategory(
                                  _selectedCategoryId!, product)
                                  .then((product) async {
                                if (_galleryViewModel.image != null) {
                                  await _uploadImage(
                                      _galleryViewModel.image!,
                                      product.idProduct);
                                  Navigator.pop(context, product);
                                } else {
                                  Navigator.pop(context, product);
                                }
                              }).catchError((error) {
                                if (error is DioError) {
                                  if (error.response?.statusCode ==
                                      400) {
                                    setState(() {
                                      errorText =
                                          AppLocalizations.of(context)!
                                              .productAlreadyExists;
                                      // _titleProductController.text =
                                      // ""; // Clear the title field
                                    });
                                  }
                                }
                              });
                            } else {
                              widget.product!.productTitle =
                                  _titleProductController.text.trim();
                              widget.product!.price = double.parse(
                                  _priceProductController.text);
                              widget.product!.description =
                                  _descriptionController.text.trim();

                              await _addProductViewModel
                                  .updateProduct(widget.product!,
                                  widget.product!.idProduct!)
                                  .then((product) async {
                                if (_galleryViewModel.image != null) {
                                  await _uploadImage(
                                      _galleryViewModel.image!,
                                      widget.product!.idProduct!);
                                  Navigator.pop(context, product);
                                } else {
                                  Navigator.pop(context, product);
                                }
                              }).catchError((error) {
                                if (error is DioError) {
                                  if (error.response?.statusCode ==
                                      400) {
                                    setState(() {
                                      errorText =
                                          AppLocalizations.of(context)!
                                              .productAlreadyExists;
                                      _titleProductController.text =
                                      ""; // Clear the title field
                                    });
                                  }
                                }
                              });
                            }
                          }
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      )
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
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
