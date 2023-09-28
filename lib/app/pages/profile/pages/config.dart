import 'dart:convert';
import 'dart:io';
import 'package:credible/app/pages/profile/blocs/config.dart';
import 'package:credible/app/pages/profile/blocs/profile.dart';
import 'package:credible/app/pages/profile/models/config.dart';
import 'package:credible/app/pages/profile/models/profile.dart';
import 'package:credible/app/pages/profile/models/root.dart';
import 'package:credible/app/shared/constants.dart';
import 'package:credible/app/shared/ui/ui.dart';
import 'package:credible/app/shared/widget/back_leading_button.dart';
import 'package:credible/app/shared/widget/base/button.dart';
import 'package:credible/app/shared/widget/base/page.dart';
import 'package:credible/app/shared/widget/base/text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({
    Key? key,
  }) : super(key: key);

  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  late TextEditingController did;
  late TextEditingController rootEventTime;
  late TextEditingController ionEndpoint;
  late TextEditingController trustchainEndpoint;
  late RootConfigModel rootConfigModel;
  late TextEditingController confirmationCodeController;
  final ValueNotifier<bool> _rootEventDateIsSet = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    final config_state = Modular.get<ConfigBloc>().state;
    final config_model =
        config_state is ConfigStateDefault ? config_state.model : ConfigModel();
    did = TextEditingController(text: config_model.did);
    rootEventTime = TextEditingController(text: config_model.rootEventTime);
    ionEndpoint = TextEditingController(text: config_model.ionEndpoint);
    trustchainEndpoint =
        TextEditingController(text: config_model.trustchainEndpoint);
    rootConfigModel = RootConfigModel(date: DateTime.now());
    confirmationCodeController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return BasePage(
      title: localizations.configTitle,
      titleLeading: BackLeadingButton(),
      titleTrailing: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: () {
          // TODO: save not working here
          Modular.get<ConfigBloc>().add(ConfigEventUpdate(ConfigModel(
            did: did.text,
            rootEventTime: rootEventTime.text,
            ionEndpoint: ionEndpoint.text,
            trustchainEndpoint: trustchainEndpoint.text,
          )));
          Modular.to.pop();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 8.0,
          ),
          child: Text(
            localizations.personalSave,
            style: Theme.of(context)
                .textTheme
                .bodyText1!
                .apply(color: UiKit.palette.primary),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 32.0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              localizations.configSubtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
          const SizedBox(height: 16.0),
          BaseTextField(
            label: localizations.didLabel,
            controller: did,
            icon: Icons.person,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16.0),
          BaseTextField(
            label: localizations.rootEventTime,
            controller: rootEventTime,
            icon: Icons.lock_clock,
            type: TextInputType.phone,
          ),
          const SizedBox(height: 16.0),
          Container(
            // color: Colors.white,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: UiKit.palette.textFieldBorder),
            ),
            child: ValueListenableBuilder<bool>(
              valueListenable: _rootEventDateIsSet,
              builder: (BuildContext context, bool value, Widget? child) {
                // This builder is called when _rootEventDateIsSet is updated.
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 12.0),
                      child: Text(
                        localizations.rootEventDate,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    // SizedBox(
                    AnimatedContainer(
                        height: _rootEventDateIsSet.value ? 30 : 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        // Date picker animation duration:
                        duration: const Duration(milliseconds: 700),
                        child: AbsorbPointer(
                          absorbing: value,
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.date,
                            initialDateTime: DateTime.now(),
                            minimumDate: DateTime(2009, 1, 3),
                            maximumDate:
                                DateTime.now().add(const Duration(days: 365)),
                            dateOrder: DatePickerDateOrder.dmy,
                            backgroundColor: Colors.white,
                            onDateTimeChanged: (DateTime newDateTime) {
                              setState(() {
                                // Refresh the rootConfigModel.
                                rootConfigModel.clear(newDateTime);
                              });
                            },
                          ),
                        )),
                    TextButton(
                      child: Text(
                        _rootEventDateIsSet.value
                            ? localizations.changeRootEventDate
                            : localizations.setRootEventDate,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: _rootEventDateIsSet.value
                                ? Colors.grey
                                : Colors.blue),
                      ),
                      onPressed: () {
                        handleRootEventDateButton();
                        // // If the date is not already set, handle setting a new root event time
                        // if (!_rootEventDateIsSet.value) {
                        //   handleSettingRootEventDate();
                        // }
                        // // Update the widget state.
                        // setState(() {
                        //   _rootEventDateIsSet.value =
                        //       !_rootEventDateIsSet.value;
                        // });
                      },
                    )
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16.0),
          BaseTextField(
            label: localizations.ionEndpoint,
            controller: ionEndpoint,
            icon: Icons.http_sharp,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16.0),
          BaseTextField(
            label: localizations.trustchainEndpoint,
            controller: trustchainEndpoint,
            icon: Icons.http_sharp,
            textCapitalization: TextCapitalization.words,
          ),
        ],
      ),
    );
  }

  void handleRootEventDateButton() async {
    // If it is not already set, handle setting a new root event date.
    if (!_rootEventDateIsSet.value) {
      // TODO:
      // - add a warning above the Set & Change root event date buttons
      // - include a call to the server to retrieve root DID candidates for the given date, etc.

      // Use the HTTP get request in practice:
      // var rootCandidates = getRootCandidates(rootConfigModel.date).await;

      // Use a test fixture while developing:
      final rootCandidateExample = jsonDecode('''{
                          "did": "did:ion:test:EiAcmytgsm-AUWtmJ9cioW-MWq-DnjIUfGYdIVUnrpg6kw",
                          "txid": "1fae017f2c9f14cec0487a04b3f1d1b7336bd38547f755748beb635296de3ee8"
                        }''');
      final rootIdentifier = RootIdentifierModel.fromMap(rootCandidateExample);
      var rootCandidates = RootCandidatesModel(
          date: rootConfigModel.date, candidates: [rootIdentifier]);
      // end of temp dev code.

      // Request the user to enter the confirmation code.
      final confCode = await requestConfirmationCode();
      if (confCode == null ||
          confCode.length < Constants.confirmationCodeMinimumLength) return;

      // Filter the root candidates w.r.t. the confirmation code.
      final matchingCandidates = rootCandidates.matchingCandidates(confCode);

      // If the confirmation code does not uniquely identify a root DID candidate, stop.
      if (matchingCandidates.length != 1) {
        await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(
                    'Invalid date/confirmation code',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: Text(
                      'The combination of root event date and confirmation code entered is not valid.\n\nPlease check and try again.'),
                  actions: [
                    TextButton(
                        child: const Text('OK'),
                        onPressed: () => Navigator.pop(context))
                  ],
                ));
        return;
      }

      // If a unique root DID has been determined ... TODO.
      setState(() {
        rootConfigModel.confimationCode = confCode;
        rootConfigModel.root = matchingCandidates.first;
        print('State updated!');
      });
    }

    // Update the widget state.
    setState(() {
      _rootEventDateIsSet.value = !_rootEventDateIsSet.value;
    });
  }

  Future<String?> requestConfirmationCode() => showDialog<String>(
        context: context,
        builder: (context) => ValueListenableBuilder(
          valueListenable: confirmationCodeController,
          builder: (context, TextEditingValue value, __) {
            return AlertDialog(
              title: Text('Confirmation code'),
              content: TextField(
                autofocus: true,
                decoration: InputDecoration(
                    hintText: 'Enter the confirmation code',
                    hintStyle: TextStyle(fontSize: 14)),
                controller: confirmationCodeController,
                onSubmitted: (_) => submitConfirmationCode(),
              ),
              actions: [
                TextButton(
                  // Disable the SUBMIT button until enough characters are entered.
                  onPressed: confirmationCodeController.value.text.length <
                          Constants.confirmationCodeMinimumLength
                      ? null
                      : submitConfirmationCode,
                  child: Text('SUBMIT'),
                )
              ],
            );
          },
        ),
      );

  void submitConfirmationCode() {
    Navigator.of(context).pop(confirmationCodeController.text);
    confirmationCodeController.clear();
  }
}
