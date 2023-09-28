import 'package:credible/app/pages/did/models/did.dart';
import 'package:credible/app/pages/did/widget/item.dart';
import 'package:credible/app/shared/globals.dart';
import 'package:credible/app/shared/ui/ui.dart';
import 'package:credible/app/shared/widget/base/box_decoration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DIDDocumentWidgetModel {
  // TODO: initial version (also to be used in the chain). Can be refined into
  // more complex widget type later (e.g. with controller, level, alias)
  final String did;
  final String endpoint;

  const DIDDocumentWidgetModel(this.did, this.endpoint);

  factory DIDDocumentWidgetModel.fromDIDModel(DIDModel model) {
    return DIDDocumentWidgetModel(model.did, model.endpoint);
  }
}

// TODO: design distinct presentation of a DID relative to credential
class DIDDocumentWidget extends StatelessWidget {
  final DIDDocumentWidgetModel model;
  final Color? color;
  final Widget? trailing;

  const DIDDocumentWidget({
    Key? key,
    this.color = const Color.fromARGB(255, 17, 0, 255),
    required this.model,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        decoration: BaseBoxDecoration(
          // TODO: update with different palette for DIDs
          // color: UiKit.palette.credentialBackground,
          // shapeColor: UiKit.palette.credentialDetail.withOpacity(0.2),
          color: color,
          value: 0.0,
          shapeSize: 256.0,
          anchors: <Alignment>[
            Alignment.topRight,
            Alignment.bottomCenter,
          ],
          // value: animation.value,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DocumentItemWidget(
                label: 'DID:',
                value: model.did,
              ),
              const SizedBox(height: 12.0),
              DocumentItemWidget(label: 'Endpoint:', value: model.endpoint),
              const SizedBox(height: 12.0),
            ],
          ),
        ),
      );
}

class HumanFriendlyDIDDocumentWidget extends StatelessWidget {
  final DIDDocumentWidgetModel model;
  final Color? color;
  final Widget? trailing;
  final String? rootEventDate;

  const HumanFriendlyDIDDocumentWidget({
    Key? key,
    this.color = const Color.fromARGB(255, 17, 0, 255),
    required this.model,
    this.trailing,
    this.rootEventDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        decoration: BaseBoxDecoration(
          // TODO [#29]: update with different palette for DIDs
          // color: UiKit.palette.credentialBackground,
          // shapeColor: UiKit.palette.credentialDetail.withOpacity(0.2),
          color: color,
          value: 0.0,
          shapeSize: 256.0,
          anchors: <Alignment>[
            Alignment.topRight,
            Alignment.bottomCenter,
          ],
          // value: animation.value,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12.0),
              // TODO: make option for FirstChainItemWidget
              ChainItemWidget(
                  did: model.did,
                  endpoint: model.endpoint,
                  rootEventDate: rootEventDate),
              const SizedBox(height: 12.0),
            ],
          ),
        ),
      );
}
