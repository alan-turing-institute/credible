import 'package:credible/app/shared/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class CancelBackLeadingButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Modular.to.pop();
      },
      icon: Icon(
        Icons.close,
        color: UiKit.palette.icon,
      ),
    );
  }
}
