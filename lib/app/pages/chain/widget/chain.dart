import 'package:credible/app/pages/chain/models/chain.dart';
import 'package:credible/app/pages/chain/widget/tile.dart';
import 'package:credible/app/pages/did/widget/document.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DIDChainWidgetModel {
  final List<DIDDocumentWidgetModel> data;
  final String? rootEventDate;

  const DIDChainWidgetModel(this.data, this.rootEventDate);

  factory DIDChainWidgetModel.fromDIDChainModel(
      DIDChainModel model, String? rootEventDate) {
    return DIDChainWidgetModel(
        model.didChain
            .map((m) => DIDDocumentWidgetModel.fromDIDModel(m))
            .toList(),
        rootEventDate);
  }
}

class DIDChainWidget extends StatelessWidget {
  final DIDChainWidgetModel model;
  final Widget? trailing;

  const DIDChainWidget({
    Key? key,
    required this.model,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(8.0),
        children: model.data.isNotEmpty
            ? model.data.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isFirst = index == 0;
                final isLast = index == model.data.length - 1;
                final rootEventDatetime =
                    DateTime.parse(model.rootEventDate ?? '');

                return CustomTile(
                  model: item,
                  isFirst: isFirst,
                  isLast: isLast,
                  rootEventDate: DateFormat('dd MMM yyyy', 'en_UK')
                      .format(rootEventDatetime),

                  // DateTime.parse(rootConfigModel),
                );
              }).toList()
            : [],
      );
}
