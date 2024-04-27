
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:hello_way/res/app_colors.dart';
class DropDownButton extends StatelessWidget {
  final String hint;
  final List<DropdownMenuItem<String>>? items;
  final void Function(String?)? onChanged;
  final void Function(String?)? onSaved;
  final String? selectedItem;
  final String? Function(String?)? validator;
  const DropDownButton({Key? key, required this.hint, this.items, this.onChanged, this.selectedItem, required this.validator, this.onSaved}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2(

      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.zero,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:  const BorderSide(
              color: orange,
            )),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: orange,
            )),
        // Added this
      ),


      hint:  Text(hint,
        style: TextStyle(fontSize: 14),
      ),
      value: selectedItem,
      items: items,
      validator: validator,
      onChanged:onChanged,
      onSaved: onSaved,
      buttonStyleData: const ButtonStyleData(
        height: 50,


      ),
      iconStyleData: const IconStyleData(
        icon: Icon(
          Icons.arrow_drop_down,
          color: Colors.black45,
        ),
        iconSize: 30,
      ),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
