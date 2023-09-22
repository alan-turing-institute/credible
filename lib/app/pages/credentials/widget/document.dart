import 'package:credible/app/pages/credentials/models/credential.dart';
import 'package:credible/app/pages/credentials/models/credential_status.dart';
import 'package:credible/app/pages/credentials/widget/document/item.dart';
import 'package:credible/app/shared/ui/ui.dart';
import 'package:credible/app/shared/widget/base/box_decoration.dart';
import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter_json_viewer/flutter_json_viewer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DocumentWidgetModel {
  final String issuedBy;
  final String status;
  final dynamic details;

  const DocumentWidgetModel(this.issuedBy, this.status, this.details);

  factory DocumentWidgetModel.fromCredentialModel(CredentialModel model) {
    late String status;

    switch (model.status) {
      case CredentialStatus.active:
        status = 'Active';
        break;
      case CredentialStatus.expired:
        status = 'Expired';
        break;
      case CredentialStatus.revoked:
        status = 'Revoked';
        break;
    }

    return DocumentWidgetModel(model.issuer, status, model.details);
  }
}

class DocumentWidget extends StatelessWidget {
  final DocumentWidgetModel model;
  final Widget? trailing;

  const DocumentWidget({
    Key? key,
    required this.model,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      decoration: BaseBoxDecoration(
        color: UiKit.palette.credentialBackground,
        shapeColor: UiKit.palette.credentialDetail.withOpacity(0.2),
        value: 0.0,
        shapeSize: 256.0,
        anchors: <Alignment>[
          Alignment.topRight,
          Alignment.bottomCenter,
        ],
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        child: ExpandablePanel(
          header: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DocumentItemWidget(
                label: 'Issued by:',
                value: model.issuedBy,
              ),
              const SizedBox(height: 24.0),
              DocumentItemWidget(label: 'Status:', value: model.status),
            ],
          ),
          collapsed: SizedBox(height: 8.0),
          expanded: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24.0),
              DocumentItemWidget(
                  label: localizations.credentialFullDetails, value: ''),
              Container(
                decoration: BaseBoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  value: 0.0,
                  shapeSize: 256.0,
                  anchors: <Alignment>[
                    Alignment.topRight,
                    Alignment.bottomCenter,
                  ],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 12.0, 8.0, 12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      JsonViewer(model.details),
                    ],
                  ), // Column
                ), // Padding
              ), // Container
            ],
          ), // Column
        ), // ExpandablePanel
      ), // Padding
    ); // Container
  }
}
