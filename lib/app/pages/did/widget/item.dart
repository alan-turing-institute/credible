import 'package:credible/app/shared/ui/ui.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:credible/app/shared/widget/base/box_decoration.dart';
import 'package:flutter_json_viewer/flutter_json_viewer.dart';

import 'document.dart';

class DocumentItemWidget extends StatelessWidget {
  final String label;
  final String value;

  const DocumentItemWidget({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .overline!
                .apply(color: UiKit.palette.credentialText.withOpacity(0.6)),
          ),
          const SizedBox(height: 2.0),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .caption!
                .apply(color: UiKit.palette.credentialText),
            maxLines: null,
            softWrap: true,
          ),
        ],
      );
}

class ChainItemWidget extends StatelessWidget {
  final String did;
  final String endpoint;
  final String humanReadableEndpoint;

  const ChainItemWidget({
    Key? key,
    required this.did,
    required this.endpoint,
    required this.humanReadableEndpoint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 2.0),
          ExpandablePanel(
            theme: const ExpandableThemeData(
                hasIcon: false,
                headerAlignment: ExpandablePanelHeaderAlignment.center),
            header: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  humanReadableEndpoint,
                  // textAlign: TextAlign.left,
                  style: Theme.of(context)
                      .textTheme
                      .caption!
                      .apply(color: UiKit.palette.credentialText),
                  maxLines: null,
                  softWrap: true,
                  textScaleFactor: 1.7,
                )
              ],
            ),
            collapsed: SizedBox(height: 0.0),
            expanded: Column(
              children: [
                SizedBox(height: 12.0),
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
                          JsonViewer({'DID': did, 'endpoint': endpoint})
                        ],
                      ), // Column
                    ))
              ],
            ),
          )
        ],
      );
}
