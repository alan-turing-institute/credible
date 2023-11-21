import 'package:credible/app/shared/ui/ui.dart';
import 'package:credible/app/shared/widget/base/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'info_dialog.dart';

class JsonInfoDialog extends InfoDialog {
  final dynamic json;
  const JsonInfoDialog({
    Key? key,
    required String title,
    String? subtitle,
    required String button,
    required this.json,
  }) : super(key: key, title: title, subtitle: subtitle, button: button);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: UiKit.palette.appBarBackground,
      contentPadding: const EdgeInsets.only(
        top: 24.0,
        bottom: 16.0,
        left: 24.0,
        right: 24.0,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.subtitle1,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (subtitle != null)
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          const SizedBox(height: 24.0),
          BaseButton.primary(
            onPressed: () {
              Modular.to.pop();
            },
            child: Text(button),
          ),
        ],
      ),
    );
  }
}
