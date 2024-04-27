import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:hello_way/models/event.dart';
import 'package:hello_way/res/app_colors.dart';
import 'package:hello_way/view/manager/display_party_image.dart';
import 'package:hello_way/widgets/app_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/network_service.dart';
import '../../utils/secure_storage.dart';
import '../../view_model/events_view_model.dart';
import '../../view_model/gallery_permission_view_model.dart';
import '../../widgets/button.dart';
import '../../widgets/input_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddPartyEvent extends StatefulWidget {
  final Event? party;
  final DateTime? startDate;
  const AddPartyEvent({Key? key, this.startDate, this.party}) : super(key: key);

  @override
  State<AddPartyEvent> createState() => _AddPartyEventState();
}

class _AddPartyEventState extends State<AddPartyEvent> {
  final SecureStorage secureStorage = SecureStorage();
  late EventsViewModel _eventsViewModel;

  final GalleryViewModel _galleryViewModel = GalleryViewModel();
  final GlobalKey<FormState> _addNewPartyFormKey = GlobalKey<FormState>();
  Color suffixColor = Colors.grey;
  late final TextEditingController _eventTitleController,
      _startDateController,
      _endDateController,
      _priceController,
      _nbPaticipantController,
      _descriptionController;

  @override
  void initState() {
    super.initState();
    _eventsViewModel = EventsViewModel(context);
    _eventTitleController = TextEditingController();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
    _priceController = TextEditingController();
    _nbPaticipantController = TextEditingController();
    _descriptionController = TextEditingController();

    if (widget.startDate != null) {
      _startDateController.text = widget.startDate!.toString();
    }

    if(widget.party!=null){
      _eventTitleController.text = widget.party!.eventTitle;
      _startDateController.text = widget.party!.startDate.toString();
      _endDateController.text = widget.party!.endDate.toString();
      _priceController.text = widget.party!.price.toString();
      _nbPaticipantController.text =widget.party!.nbParticipant.toString();
      _descriptionController.text = widget.party!.description;
    }
  }

  @override
  void dispose() {
    _eventTitleController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _priceController.dispose();
    _nbPaticipantController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
      return  AppLocalizations.of(context)!.endDateMustBeGreaterThanStartDate;
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
        title: AppLocalizations.of(context)!.partyEvent,
      ),
      body:networkStatus == NetworkStatus.Online
          ? Form(
        key: _addNewPartyFormKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
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
                          hint: AppLocalizations.of(context)!
                              .numberOfParticipants,
                          keyboardType: TextInputType.number,
                          controller: _nbPaticipantController,
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
                          hint: AppLocalizations.of(context)!.price,
                          keyboardType: TextInputType.number,
                          controller: _priceController,
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
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
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
                                hintText:
                                    AppLocalizations.of(context)!.startDate,
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
                                      String formatted =
                                          formatter.format(picked);
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
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
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
                          maxLines: 5,
                          hint: AppLocalizations.of(context)!.description,
                          controller: _descriptionController,
                          validator: MultiValidator([
                            RequiredValidator(
                                errorText: AppLocalizations.of(context)!
                                    .inputRequiredError),
                          ]),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        MultiProvider(
                            providers: [
                              ChangeNotifierProvider(
                                  create: (_) => _galleryViewModel),
                            ],
                            child: Consumer<GalleryViewModel>(
                              builder: (context, galleryViewModel, _) => Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8.0),
                                    child: Icon(
                                      Icons.image_outlined,
                                      size: 35,
                                      color: gray,
                                    ),
                                  ),
                          Expanded( // Wrap the Column with Expanded
                            child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (_galleryViewModel.image != null)
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    DisplayPartyImage(
                                                  image:
                                                      _galleryViewModel.image!,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text(

                                            _galleryViewModel.image!.path
                                                .split("/")
                                                .last,
                                            overflow: TextOverflow.ellipsis, // Display ellipsis when text overflows
                                            maxLines: 1,
                                          ), // Replace 'Click Me' with the desired button label
                                        ),
                                      TextButton(
                                        onPressed: () async {
                                          bool isGranted =
                                              await galleryViewModel
                                                  .requestGalleryPermission(
                                                      context);
                                          if (isGranted) {
                                            await galleryViewModel
                                                .selectImage();
                                            print(_galleryViewModel.image!);
                                          } else {
                                            // Do something when permission is not granted
                                          }
                                        },
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .addAnImage,
                                            style: const TextStyle(
                                              color: gray,
                                            )), // Replace 'Click Me' with the desired button label
                                      )
                                    ],
                            )                                  )
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: orange,
                            ),
                            child: Button(
                                text: widget.party==null?AppLocalizations.of(context)!.add:AppLocalizations.of(context)!.modify,
                                onPressed: () {
                                  if (_addNewPartyFormKey.currentState!
                                      .validate()) {
                                    _addNewPartyFormKey.currentState!.save();
                                    Event event = Event(
                                        eventTitle: _eventTitleController.text
                                            .trim()
                                            .toString(),
                                        startDate: DateTime.parse(
                                            _startDateController.text
                                                .trim()
                                                .toString()),
                                        endDate: DateTime.parse(
                                            _endDateController.text
                                                .trim()
                                                .toString()),
                                        description: _descriptionController.text
                                            .trim()
                                            .toString(),
                                        nbParticipant: int.parse(
                                            _nbPaticipantController.text
                                                .trim()),
                                        price: double.parse(
                                            _priceController.text.trim()));

                                    _eventsViewModel
                                        .createPartyForSpace(event)
                                        .then((event) async {
                                      if (_galleryViewModel.image != null) {
                                        await _eventsViewModel
                                            .uploadImage(
                                                _galleryViewModel.image!,
                                                event.idEvent!)
                                            .then((_) {
                                          Navigator.pop(context);
                                        }).catchError((error) {
                                          print(error);
                                        });
                                      } else {
                                        Navigator.pop(context);
                                      }
                                    }).catchError((error) {
                                      print(error);
                                    });
                                  }
                                })),
                      ),
                    ],
                  )),
            )
          ],
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
      ),
    );
  }
}
