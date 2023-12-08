import 'dart:collection';

import 'package:credible/app/pages/attributes/models/attributes.dart';
import 'package:credible/app/pages/credentials/widget/list_item.dart';
import 'package:credible/app/shared/ui/ui.dart';
import 'package:credible/app/shared/widget/base/button.dart';
import 'package:credible/app/shared/widget/base/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AttributesPickPage extends StatefulWidget {
  final AttributesModel items;
  final void Function(AttributesModel) onSubmit;

  const AttributesPickPage({
    Key? key,
    required this.items,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _AttributesPickPageState createState() => _AttributesPickPageState();
}

class _AttributesPickPageState extends State<AttributesPickPage> {
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

    return BasePage(
      title: 'Select attributes',
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
          height: kBottomNavigationBarHeight * 1.75,
          child: Tooltip(
            message: localizations.credentialPickPresent,
            child: BaseButton.primary(
              onPressed: () {
                if (selection.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: Colors.red,
                    content: Text(localizations.credentialPickFieldsSelect),
                  ));
                } else {
                  widget.onSubmit(widget.items.mask(selection));
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
            widget.items.attributes.length,
            (index) => AttributesListItem(
              item: widget.items.attributes[index],
              selected: selection.contains(index),
              onTap: () => toggle(index),
            ),
          ),
        ],
      ),
    );
  }
}
