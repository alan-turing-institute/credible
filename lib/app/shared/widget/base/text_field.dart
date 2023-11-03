import 'package:credible/app/shared/ui/ui.dart';
import 'package:flutter/material.dart';

class BaseTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final TextInputType type;
  final TextCapitalization textCapitalization;
  final String? error;
  final double padding;
  final bool includeDecoration;
  final bool readOnly;

  const BaseTextField(
      {Key? key,
      required this.label,
      required this.controller,
      this.icon,
      this.type = TextInputType.text,
      this.textCapitalization = TextCapitalization.none,
      this.error,
      this.padding = 24.0,
      this.includeDecoration = true,
      this.readOnly = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: UiKit.constraints.textFieldPadding,
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        // horizontal: 1.0,
      ),
      decoration: includeDecoration
          ? BoxDecoration(
              color: UiKit.palette.textFieldBackground,
              border: Border.all(color: UiKit.palette.textFieldBorder),
              borderRadius: UiKit.constraints.textFieldRadius,
            )
          : BoxDecoration(),
      child: TextFormField(
        controller: controller,
        cursorColor: UiKit.text.colorTextBody1,
        keyboardType: type,
        maxLines: 1,
        textCapitalization: textCapitalization,
        readOnly: readOnly,
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          fillColor: UiKit.text.colorTextBody1,
          hoverColor: UiKit.text.colorTextBody1,
          focusColor: UiKit.text.colorTextBody1,
          errorText: error,
          hintText: label,
          hintStyle: Theme.of(context).textTheme.bodyText1!,
          labelText: label,
          labelStyle: Theme.of(context).textTheme.bodyText1!,
          suffixIcon: Icon(
            icon,
            color: UiKit.palette.icon.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}
