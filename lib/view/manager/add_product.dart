import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:hello_way/models/product.dart';
import 'package:hello_way/view_model/products_view_model.dart';
import 'package:hello_way/widgets/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
import '../../res/app_colors.dart';
import '../../services/network_service.dart';
import '../../utils/secure_storage.dart';
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
  final GlobalKey<FormState> _addProductFormKey = GlobalKey<FormState>();
  late final TextEditingController _titleProductController,
      _priceProductController,
      _descriptionController;
  String? errorText;
  bool _submitted = false;

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
        errorText = null;
        if (_submitted) {
          _addProductFormKey.currentState?.validate();
        }
      });
    });
  }

  @override
  void dispose() {
    _titleProductController.dispose();
    _priceProductController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _validationTitle(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.inputRequiredError;
    }
    final pattern = RegExp(r'^[\w\sàâäéèêëîïôöùûüçÀÂÄÉÈÊËÎÏÔÖÙÛÜÇ_ :\-]+$', caseSensitive: false);
    if (!pattern.hasMatch(value)) {
      return 'Only letters, specific characters, spaces, and underscores are allowed.';
    }
    return null;
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
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                Consumer<ProductsViewModel>(
                  builder: (context, galleryViewModel, _) => Container(
                    color: lightGray,
                    height: 250,
                    width: MediaQuery.of(context).size.width,
                    child: const Icon(
                      Icons.image,
                      color: gray,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      InputForm(
                        hint: AppLocalizations.of(context)!.title,
                        controller: _titleProductController,
                        validator: _validationTitle,
                      ),
                      const SizedBox(height: 10),
                      InputForm(
                        hint: AppLocalizations.of(context)!.price,
                        keyboardType: TextInputType.number,
                        controller: _priceProductController,
                        validator: MultiValidator([
                          RequiredValidator(
                            errorText: AppLocalizations.of(context)!.inputRequiredError,
                          ),
                          PatternValidator(
                            r'^\d+',
                            errorText: AppLocalizations.of(context)!.nigativeError,
                          ),
                        ]),
                      ),
                      const SizedBox(height: 10),
                      InputForm(
                        maxLines: 5,
                        hint: AppLocalizations.of(context)!.description,
                        controller: _descriptionController,
                      ),
                      const SizedBox(height: 20),
                      if (errorText != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Text(
                            errorText!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      Button(
                        text: widget.product == null
                            ? AppLocalizations.of(context)!.add
                            : AppLocalizations.of(context)!.modify,
                        onPressed: () async {
                          setState(() {
                            _submitted = true;
                          });
                          if (_addProductFormKey.currentState!.validate()) {
                            _addProductFormKey.currentState!.save();
                            if (widget.product == null) {
                              final _selectedCategoryId =
                              await secureStorage.readData('categoryId');
                              Product product = Product(
                                productTitle: _titleProductController.text.trim(),
                                price: double.parse(_priceProductController.text),
                                description: _descriptionController.text.trim(),
                                available: true,
                              );
                              await _addProductViewModel
                                  .addProductByIdCategory(
                                  _selectedCategoryId!, product)
                                  .then((product) {
                                Navigator.pop(context, product);
                              }).catchError((error) {
                                if (error is DioError && error.response?.statusCode == 400) {
                                  setState(() {
                                    errorText = AppLocalizations.of(context)!
                                        .productAlreadyExists;
                                  });
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
            ],
          ),
        ),
      ),
    );
  }
}
