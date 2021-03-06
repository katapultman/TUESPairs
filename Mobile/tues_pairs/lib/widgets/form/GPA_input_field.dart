import 'package:flutter/material.dart';
import 'package:tues_pairs/modules/user.dart';
import 'package:tues_pairs/shared/constants.dart';
import 'package:tues_pairs/widgets/form/input_field.dart';

import '../../locale/app_localization.dart';

class GPAInputField extends InputField {

  GPAInputField({
    Key key,
    @required Function onChanged,
    String initialValue,
    String hintText = 'enterGPA',
    int maxLines
  }) : super(
      key: key,
      onChanged: onChanged,
      initialValue: initialValue,
      hintText: hintText,
      maxLines: maxLines,
    );

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizator = AppLocalizations.of(context);

    return TextFormField( // if the current user wants to be a teacher, he doesn't need GPA field
      // parse the given string to a double
      initialValue: initialValue ?? '',
      onChanged: onChanged,
      style: textInputColor,
      validator: (value) {
        double GPA = double.tryParse(value);
        if(GPA == null || value.isEmpty || GPA < 2 || GPA > 6) {
          return localizator.translate('incorrectGPA');
        }
        return null;
      },
      keyboardType: TextInputType.number,
      decoration: textInputDecoration.copyWith(
        icon: Icon(
          Icons.border_color,
          color: Colors.orange,
        ),
        hintText: localizator.translate(hintText),
      ),
    );
  }
}
