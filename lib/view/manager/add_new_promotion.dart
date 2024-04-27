import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:hello_way/models/event.dart';
import 'package:hello_way/models/product.dart';
import 'package:hello_way/res/app_colors.dart';
import 'package:hello_way/widgets/app_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/network_service.dart';
import '../../utils/secure_storage.dart';
import '../../view_model/events_view_model.dart';
import '../../widgets/button.dart';
import '../../widgets/input_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddNewPromotion extends StatefulWidget {
  final Product? product;
  final bool? hasActivePromotion;
  final int? promotionId;
  const AddNewPromotion(
      {Key? key,  this.product, this.hasActivePromotion, this.promotionId})
      : super(key: key);

  @override
  State<AddNewPromotion> createState() => _AddNewPromotionState();
}

class _AddNewPromotionState extends State<AddNewPromotion> {
  final SecureStorage secureStorage = SecureStorage();
  late EventsViewModel _eventsViewModel ;
  final GlobalKey<FormState> _addNewPromotionFormKey = GlobalKey<FormState>();
  Color suffixColor = Colors.grey;
  late final TextEditingController _eventTitleController,
      _startDateController,
      _endDateController,
      _percentageController,
      _descriptionController;

  Event? event;
  @override
  void initState() {
    super.initState();
    _eventsViewModel = EventsViewModel(context);
    if(widget.promotionId!=null){
      getEventById();
    }
      _eventTitleController = TextEditingController();
      _startDateController = TextEditingController();
      _endDateController = TextEditingController();
      _percentageController = TextEditingController();
      _descriptionController = TextEditingController();



  }

  @override
  void dispose() {



    _eventTitleController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _percentageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  Future<void> getEventById() async {
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    await _eventsViewModel.fetchEventById(widget.promotionId!).then((promotion) async {
      setState(() {
        event=promotion;
      });
      _eventTitleController.text=promotion.eventTitle;
      _startDateController.text=formatter.format(promotion.startDate);
      _endDateController.text=formatter.format(promotion.endDate);
      _percentageController.text=promotion.percentage.toString();
      _descriptionController.text=promotion.description;
    }).catchError((error) {});

  }

  String? _validateStartDate(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.inputRequiredError;
    }
    return null;
  }

  String? _validateEndDate(String? value) {
    DateTime startDate =
        DateTime.parse(_startDateController.text.trim().toString());
    DateTime? endDate = DateTime.tryParse(value!);
    if (endDate == null) {
      return AppLocalizations.of(context)!.inputRequiredError;
    }

    if (endDate.isBefore(startDate)) {
      return AppLocalizations.of(context)!.endDateMustBeGreaterThanStartDate;
    }

    return null;
  }

  Future<DateTime?> _selectDateTime(BuildContext context) async {
    DateTime? selectedDateTime;

    // Show the date picker
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(5000),
    );

    if (pickedDate != null) {
      // Show the time picker
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        // Combine the date and time
        selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    }

    return selectedDateTime;
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: Toolbar(
          title: AppLocalizations.of(context)!.promotion,
        ),
        body:networkStatus == NetworkStatus.Online
            ? Form(
          key: _addNewPromotionFormKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                widget.product!=null?
                Container(
                    color: lightGray,
                    height: 220,
                    width: MediaQuery.of(context).size.width,
                    child: FittedBox(
                        fit: BoxFit.fill,
                        child: widget.product!.images!.isNotEmpty
                            ? Image.memory(
                                base64.decode(widget.product!.images![widget.product!.images!.length-1].data))
                            : const Icon(
                                Icons.restaurant_menu_rounded,
                                color: gray,
                              ))):Text("Edit"),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(children: [
                    const SizedBox(
                      height: 20,
                    ),
                    InputForm(
                      hint: AppLocalizations.of(context)!.title,
                      controller: _eventTitleController,
                      validator: MultiValidator([
                        RequiredValidator(
                            errorText: AppLocalizations.of(context)!
                                .inputRequiredError),
                      ]),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InputForm(
                      hint: AppLocalizations.of(context)!.percentage,
                      keyboardType: TextInputType.number,
                      controller: _percentageController,
                      validator: MultiValidator([
                        RequiredValidator(
                            errorText: AppLocalizations.of(context)!
                                .inputRequiredError),
                      ]),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Focus(
                      onFocusChange: (hasFocus) {
                        setState(() {
                          (hasFocus)
                              ? suffixColor = orange
                              : suffixColor = Colors.grey;
                        });
                      },
                      child: TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: _validateStartDate,
                          controller: _startDateController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 16),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: orange,
                                )),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: orange,
                                )),
                            hintText: AppLocalizations.of(context)!.startDate,
                            suffixIcon: Icon(
                              Icons.calendar_today,
                              color: suffixColor,
                            ),
                          ),
                          readOnly: true, // when true user cannot edit text
                          onTap: () async {
                            _selectDateTime(context).then((picked) async {
                              if (picked != null) {
                                setState(() {
                                  DateFormat formatter =
                                      DateFormat('yyyy-MM-dd HH:mm');
                                  String formatted = formatter.format(picked);
                                  _startDateController.text = formatted;
                                });
                              }
                            }).catchError((error) {});
                            //when click we have to show the datepicker
                          }),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Focus(
                      onFocusChange: (hasFocus) {
                        setState(() {
                          (hasFocus)
                              ? suffixColor = orange
                              : suffixColor = Colors.grey;
                        });
                      },
                      child: TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: _validateEndDate,
                          controller: _endDateController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 16),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: orange,
                                )),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: orange,
                                )),
                            hintText: AppLocalizations.of(context)!.endDate,
                            suffixIcon: Icon(
                              Icons.calendar_today,
                              color: suffixColor,
                            ),
                          ),
                          readOnly: true, // when true user cannot edit text
                          onTap: () async {
                            _selectDateTime(context).then((picked) async {
                              if (picked != null &&
                                  _startDateController.text.isNotEmpty) {
                                setState(() {
                                  DateFormat formatter =
                                      DateFormat('yyyy-MM-dd HH:mm');
                                  String formatted = formatter.format(picked);
                                  _endDateController.text = formatted;
                                });
                              }
                            }).catchError((error) {});
                            //when click we have to show the datepicker
                          }),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InputForm(
                      maxLines: 3,
                      hint: AppLocalizations.of(context)!.description,
                      controller: _descriptionController,
                      validator: MultiValidator([
                        RequiredValidator(
                            errorText: AppLocalizations.of(context)!
                                .inputRequiredError),
                      ]),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Button(
                      text:     widget.promotionId==null? AppLocalizations.of(context)!.add:AppLocalizations.of(context)!.modify,
                      onPressed: () async {
                        if (_addNewPromotionFormKey.currentState!.validate()) {
                          _addNewPromotionFormKey.currentState!.save();
                          Event event = Event(
                              eventTitle:
                              _eventTitleController.text.trim().toString(),
                              startDate: DateTime.parse(
                                  _startDateController.text.trim().toString()),
                              endDate: DateTime.parse(
                                  _endDateController.text.trim().toString()),
                              description:
                              _descriptionController.text.trim().toString(),
                              percentage:
                              int.parse(_percentageController.text.trim()));


                          if(widget.promotionId==null){

                          _eventsViewModel.createPromotionForSpace(
                              event, widget.product!.idProduct!).then((_) {
                            Navigator.pop(context);
                          }).catchError((error) {
                            print(error);
                          });
                          }else{
                            event.idEvent=  widget.promotionId;


                        print(event.idEvent);
                              _eventsViewModel.updatePromotion( event).then((updatedEvent) {
                                Navigator.pop(context);
                              }).catchError((error) {
                                print(error);
                              });
                        }}
                      },
                    )
                  ]),
                ),
              ],
            ),
          ),
        ):Center(
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
                const SizedBox(height: 10,),
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
