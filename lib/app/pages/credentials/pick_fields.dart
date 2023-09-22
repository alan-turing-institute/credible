import 'dart:convert';

import 'package:credible/app/interop/trustchain/trustchain.dart';
import 'package:credible/app/pages/credentials/models/credential.dart';
import 'package:credible/app/pages/credentials/widget/field_list_item.dart';
import 'package:credible/app/shared/ui/ui.dart';
import 'package:credible/app/shared/widget/base/button.dart';
import 'package:credible/app/shared/widget/base/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CredentialsPickFieldsPage extends StatefulWidget {
  final CredentialModel item;
  final void Function(List<int>) onSubmit;

  const CredentialsPickFieldsPage({
    Key? key,
    required this.item,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _CredentialsPickPageState createState() => _CredentialsPickPageState();
}

class _CredentialsPickPageState extends State<CredentialsPickFieldsPage> {
  final selection = <int>{};

  void toggle(int index) {
    if (selection.contains(index)) {
      selection.remove(index);
    } else {
      selection.add(index);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    List<dynamic> fields = jsonDecode(trustchain_ffi.flattenCredential(credential: jsonEncode(widget.item.data)));

    return BasePage(
      title: 'Present credentials',
      titleTrailing: IconButton(
        onPressed: () {
          Modular.to.pushReplacementNamed('/credentials/list');
        },
        icon: Icon(
          Icons.close,
          color: UiKit.palette.icon,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 24.0,
        horizontal: 16.0,
      ),
      navigation: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          height: kBottomNavigationBarHeight * 1.5,
          child: Tooltip(
            message: localizations.credentialPickPresent,
            child: BaseButton.primary(
              onPressed: () {
                if (selection.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: Colors.red,
                    content: Text(localizations.credentialPickSelect),
                  ));
                } else {
                  widget
                      .onSubmit(selection.toList());
                  Modular.to.pushReplacementNamed('/credentials/list');
                }
              },
              child: Text(localizations.credentialPickPresent),
            ),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Text(
            localizations.credentialPickFieldsSelect,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          const SizedBox(height: 32.0),
          ...List.generate(
            fields.length,
            (index) => CredentialFieldsListItem(
              item: fields[index],
              selected: selection.contains(index),
              onTap: () => toggle(index),
            ),
          ),
        ],
      ),
    );
  }
}
