import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:hello_way/models/primary_material.dart';
import 'package:hello_way/res/app_colors.dart';
import 'package:hello_way/utils/const.dart';
import 'package:hello_way/widgets/app_bar.dart';
import 'package:provider/provider.dart';
import '../../services/network_service.dart';
import '../../view_model/stock_view_model.dart';
import '../../widgets/button.dart';
import '../../widgets/dropdown_button.dart';
import '../../widgets/input_form.dart';
import '../../widgets/snack_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddPrimaryMaterial extends StatefulWidget {
  final PrimaryMaterial? primaryMaterial;
  const AddPrimaryMaterial({
    Key? key,
    this.primaryMaterial,
  }) : super(key: key);

  @override
  State<AddPrimaryMaterial> createState() => _AddPrimaryMaterialState();
}

class _AddPrimaryMaterialState extends State<AddPrimaryMaterial> {
  late StockViewModel _stockViewModel;
  final GlobalKey<FormState> _addPrimaryMaterialFormKey =
  GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> _addPrimaryMaterialScaffoldKey =
  GlobalKey<ScaffoldMessengerState>();
  String? _selectedUnitOfMeasure;
  late final TextEditingController _titleController,
      _quantityController,
      _priceController,
      _descriptionController,
      _supplierController,
      _supplierNumberController;

  @override
  void initState() {
    super.initState();
    _stockViewModel = StockViewModel(context);
    _titleController = TextEditingController();
    _quantityController = TextEditingController();
    _priceController = TextEditingController();
    _descriptionController = TextEditingController();
    _supplierController = TextEditingController();
    _supplierNumberController = TextEditingController();
    if (widget.primaryMaterial != null) {
      _titleController.text = widget.primaryMaterial!.title;
      _quantityController.text =
          widget.primaryMaterial!.stockQuantity.toString();
      _priceController.text = widget.primaryMaterial!.price.toString();
      _descriptionController.text = widget.primaryMaterial!.description;
      _supplierController.text = widget.primaryMaterial!.supplier;
      _supplierNumberController.text = widget.primaryMaterial!.supplierNumber;
      setState(() {
        _selectedUnitOfMeasure = widget.primaryMaterial!.unitOfMeasure;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _supplierController.dispose();
    _supplierNumberController.dispose();
    super.dispose();
  }

  void _clearInputFields() {
    _titleController.clear();
    _descriptionController.clear();
    _selectedUnitOfMeasure = null;
    _quantityController.clear();
    _priceController.clear();
    _supplierController.clear();
    _supplierNumberController.clear();
  }

  String? _titleValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.inputRequiredError;
    }
    final pattern = RegExp(r'^[a-zA-Z0-9 _]+$');
    if (!pattern.hasMatch(value)) {
      return 'Only letters, numbers, spaces, and underscores are allowed.';
    }
    return null;
  }

  String sanitizeTitle(String title) {
    return title.toLowerCase().replaceAll(RegExp(r'[_ ]'), '');
  }

  Future<void> _handleFormSubmission() async {
    if (_addPrimaryMaterialFormKey.currentState!.validate()) {
      _addPrimaryMaterialFormKey.currentState!.save();
      String sanitizedInputTitle = sanitizeTitle(_titleController.text.trim());
      bool titleExists = await _stockViewModel.checkTitleExists(sanitizedInputTitle);
      var primaryMaterial = PrimaryMaterial(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        unitOfMeasure: _selectedUnitOfMeasure!,
        stockQuantity: double.parse(_quantityController.text.trim()),
        price: double.parse(_priceController.text.contains(',')
            ? _priceController.text.replaceAll(',', '.')
            : _priceController.text),
        supplier: _supplierController.text.trim(),
        supplierNumber: _supplierNumberController.text.trim(),
      );
    if(widget.primaryMaterial! ==null){
      if (!titleExists) {
        _stockViewModel.addPrimaryMaterialToSpace(primaryMaterial).then((primaryMaterial) async {
          Navigator.pop(context, primaryMaterial);
        }).catchError((error) {
          // Handle error
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Title already exists in the database.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }else{
      _stockViewModel.updatePrimaryMaterialInSpace(
          widget.primaryMaterial!.id!,
          primaryMaterial
      ).then((primaryMaterial) async {
        Navigator.pop(context, primaryMaterial);
      }).catchError((error) {});
        // var primaryMaterial = PrimaryMaterial(
        //   title: _titleController.text.trim(),
        //   description: _descriptionController.text.trim(),
        //   unitOfMeasure: _selectedUnitOfMeasure!,
        //   stockQuantity: double.parse(_quantityController.text.trim()),
        //   price: double.parse(_priceController.text.contains(',')
        //       ? _priceController.text.replaceAll(',', '.')
        //       : _priceController.text),
        //   supplier: _supplierController.text.trim(),
        //   supplierNumber: _supplierNumberController.text.trim(),
        // );
        _stockViewModel.addPrimaryMaterialToSpace(primaryMaterial).then((primaryMaterial) async {
          Navigator.pop(context, primaryMaterial);
        }).catchError((error) {
          // Handle error
        });

      }
    }

    }

  String? _customValidator(String? value) {
    if (value != null && value.isNotEmpty) {
      // Check if the value contains a dot (.) or comma (,)
      if (value.contains('.') || value.contains(',')) {
        return AppLocalizations.of(context)!.dotsOrcommasError;
      }

      int? numberOfParticipants = int.tryParse(value);
      if (numberOfParticipants == null) {
        return AppLocalizations.of(context)!.inputRequiredError;
      } else if (numberOfParticipants < 0) {
        return AppLocalizations.of(context)!.nigativeError;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    final listUnits = initListUnits(context);
    return ScaffoldMessenger(
      key: _addPrimaryMaterialScaffoldKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: Toolbar(
          title: AppLocalizations.of(context)!.primaryMaterial,
        ),
        body: networkStatus == NetworkStatus.Online
            ? Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  final FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                },
                child: SingleChildScrollView(
                  child: Form(
                    key: _addPrimaryMaterialFormKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              InputForm(
                                hint: AppLocalizations.of(context)!.title,
                                controller: _titleController,
                                validator: _titleValidator,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: InputForm(
                                      hint: AppLocalizations.of(context)!.quantity,
                                      keyboardType: TextInputType.number,
                                      controller: _quantityController,
                                      validator: _customValidator,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: DropDownButton(
                                      hint: AppLocalizations.of(context)!.unit,
                                      items: listUnits.map((String unit) {
                                        return DropdownMenuItem<String>(
                                          value: unit,
                                          child: Text(unit),
                                        );
                                      }).toList(),
                                      onChanged: (String? selectedItem) async {
                                        setState(() {
                                          _selectedUnitOfMeasure = selectedItem;
                                        });
                                      },
                                      validator: MultiValidator([
                                        RequiredValidator(
                                            errorText: AppLocalizations.of(context)!.inputRequiredError),
                                      ]),
                                      selectedItem: _selectedUnitOfMeasure,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              InputForm(
                                hint: AppLocalizations.of(context)!.price,
                                keyboardType: TextInputType.number,
                                controller: _priceController,
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
                                hint: AppLocalizations.of(context)!.supplier,
                                controller: _supplierController,
                                validator: MultiValidator([
                                  RequiredValidator(
                                      errorText: AppLocalizations.of(context)!.inputRequiredError),
                                ]),
                              ),
                              const SizedBox(height: 10),
                              InputForm(
                                keyboardType: TextInputType.number,
                                hint: AppLocalizations.of(context)!.supplierNumber,
                                controller: _supplierNumberController,
                                contentPadding: const EdgeInsets.all(10),
                                validator: MultiValidator([
                                  RequiredValidator(
                                      errorText: AppLocalizations.of(context)!.phoneRequiredError),
                                  LengthRangeValidator(
                                      min: 8,
                                      max: 12,
                                      errorText: AppLocalizations.of(context)!.phoneLengthError),
                                  PatternValidator(
                                      r'(^(?:\+216)?[0-9]{8}$)',
                                      errorText: AppLocalizations.of(context)!.phonePatternError),
                                ]),
                              ),
                              const SizedBox(height: 10),
                              InputForm(
                                maxLines: 5,
                                hint: AppLocalizations.of(context)!.description,
                                controller: _descriptionController,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Button(
                  text: widget.primaryMaterial == null
                      ? AppLocalizations.of(context)!.add
                      : AppLocalizations.of(context)!.modify,
                  onPressed: _handleFormSubmission,
                ),
              ),
            ),
          ],
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
