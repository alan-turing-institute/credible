import 'dart:convert';

import 'package:credible/app/interop/secure_storage/secure_storage.dart';
import 'package:credible/app/interop/trustchain/trustchain.dart';
import 'package:credible/app/pages/credentials/blocs/scan.dart';
import 'package:credible/app/pages/profile/blocs/config.dart';
import 'package:credible/app/pages/profile/models/config.dart';
import 'package:credible/app/pages/profile/models/root.dart';
import 'package:credible/app/pages/profile/module.dart';
import 'package:credible/app/shared/config.dart';
import 'package:credible/app/shared/constants.dart';
import 'package:credible/app/shared/globals.dart';
import 'package:credible/app/shared/model/message.dart';
import 'package:credible/app/shared/ui/ui.dart';
import 'package:credible/app/shared/widget/back_leading_button.dart';
import 'package:credible/app/shared/widget/base/page.dart';
import 'package:credible/app/shared/widget/base/text_field.dart';
import 'package:credible/app/shared/widget/confirm_dialog.dart';
import 'package:dio/dio.dart';
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
  late TextEditingController trustchainEndpoint;
  late RootConfigModel rootConfigModel;
  late TextEditingController confirmationCodeController;
  late String didIon;
  late String didKey;
  bool didIonMethod = false;
  final ValueNotifier<bool> _rootEventDateIsSet = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    final config_state = Modular.get<ConfigBloc>().state;
    var config_model =
        config_state is ConfigStateDefault ? config_state.model : ConfigModel();
    did = TextEditingController(text: config_model.did());
    didIon = config_model.didIon;
    didKey = config_model.didKey;
    didIonMethod = config_model.didIonMethod == 'false' ? false : true;
    trustchainEndpoint =
        TextEditingController(text: config_model.trustchainEndpoint);
    // Initialise the root config model:
    _rootEventDateIsSet.value = config_model.rootEventDate.isNotEmpty;
    var rootIdentifier = config_model.rootDid.isEmpty
        ? null
        : RootIdentifierModel(
            did: config_model.rootDid,
            txid: config_model.rootTxid,
            blockHeight: int.parse(config_model.rootBlockHeight));
    rootConfigModel = RootConfigModel(
        date: config_model.rootEventDate.isEmpty
            ? DateTime.now().subtract(const Duration(days: 1))
            : DateTime.parse(config_model.rootEventDate),
        confimationCode: config_model.confirmationCode,
        root: rootIdentifier,
        timestamp: config_model.rootEventTime.isEmpty
            ? null
            : parseIntOrNull(config_model.rootEventTime));
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
          Modular.get<ConfigBloc>().add(ConfigEventUpdate(ConfigModel(
            didIon: didIon,
            didKey: didKey,
            didIonMethod: didIonMethod.toString(),
            trustchainEndpoint: trustchainEndpoint.text,
            rootEventDate: _rootEventDateIsSet.value
                ? rootConfigModel.date.toString()
                : '',
            confirmationCode: rootConfigModel.confimationCode.toString(),
            rootDid:
                rootConfigModel.root == null ? '' : rootConfigModel.root!.did,
            rootTxid:
                rootConfigModel.root == null ? '' : rootConfigModel.root!.txid,
            rootBlockHeight: rootConfigModel.root == null
                ? ''
                : rootConfigModel.root!.blockHeight.toString(),
            rootEventTime: rootConfigModel.timestamp == null
                ? ''
                : rootConfigModel.timestamp.toString(),
          )));
          // TODO: fix to reload ProfilePage so that DID is updated
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
          // TODO: move to a separate rootEventDate widget.
          Container(
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
                            initialDateTime: rootConfigModel.date,
                            minimumDate: DateTime(2009, 1, 3),
                            maximumDate:
                                DateTime.now().add(const Duration(days: 365)),
                            dateOrder: DatePickerDateOrder.dmy,
                            backgroundColor: Colors.white,
                            onDateTimeChanged: (DateTime newDateTime) {
                              setState(() {
                                // Refresh the rootConfigModel & set the new date.
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
                      },
                    )
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16.0),
          Container(
              decoration: BoxDecoration(
                color: UiKit.palette.textFieldBackground,
                border: Border.all(color: UiKit.palette.textFieldBorder),
                borderRadius: UiKit.constraints.textFieldRadius,
              ),
              child: Column(
                children: [
                  BaseTextField(
                      label: localizations.didLabel,
                      controller: did,
                      padding: 24.0,
                      readOnly: true,
                      includeDecoration: false),
                  SwitchListTile(
                    tileColor: Color.fromARGB(255, 255, 255, 255),
                    title: const Text('DID ION mode'),
                    contentPadding: EdgeInsets.symmetric(horizontal: 24.0),
                    subtitle: Text('Use did:ion instead of did:key'),
                    value: didIonMethod,
                    onChanged: (bool value) async {
                      if (value) {
                        // Check if published
                        try {
                          // No need to publish
                          final response =
                              Map.from((await resolveDidResponse(didIon)).data);
                          print(response);
                          assert(response.containsKey('didDocument'));
                        } catch (err) {
                          print(err);
                          // If not published, confirm submission
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return ConfirmDialog(
                                title: 'Publish DID',
                                subtitle:
                                    'Do you wish to publish your did:ion DID?',
                                yes: 'Publish',
                                no: 'Cancel',
                              );
                            },
                          );
                          // As awaited cannot be null
                          if (confirm!) {
                            final mnemonic = (await SecureStorageProvider
                                .instance
                                .get('mnemonic'))!;
                            final createOp = jsonDecode(
                                (await trustchain_ffi.createOperationMnemonic(
                                    mnemonic: mnemonic)))['createOperation'];
                            // Send create operation
                            final uri = Uri.parse((await ffi_config_instance
                                    .get_trustchain_endpoint()) +
                                '/operations');
                            try {
                              await Dio().post(uri.toString(),
                                  data: jsonEncode(createOp));
                              showOkDialog(
                                  'Success',
                                  'Your ION DID has been published.\n\n'
                                      'It will be visible to others shortly.',
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.green,
                                    size: 50,
                                  ),
                                  13.5);
                            } catch (err) {
                              value = false;
                              showOkDialog(
                                  'Failed to publish DID', 'Error: $err');
                            }
                          } else {
                            value = false;
                          }
                        }
                      }
                      setState(() {
                        didIonMethod = value;
                        did.text = didIonMethod == false ? didKey : didIon;
                      });
                    },
                  ),
                ],
              )),
          const SizedBox(height: 16.0),
          BaseTextField(
            label: localizations.trustchainEndpoint,
            controller: trustchainEndpoint,
            padding: 24.0,
            icon: Uri.parse(trustchainEndpoint.text).scheme == 'https'
                ? Icons.https_sharp
                : Icons.http_sharp,
            textCapitalization: TextCapitalization.words,
          ),
        ],
      ),
    );
  }

  void publishDIDION() async {}

  void handleRootEventDateButton() async {
    // If it is not already set, handle setting a new root event date.
    if (!_rootEventDateIsSet.value) {
      // If the selected date is not in the past, show an Error.
      if (!rootConfigModel.date
          .isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
        showOkDialog('Invalid date',
            'The root event date must be in the past. Please try again.');
        return;
      }
      // Get the root DID candidates via an HTTP request.
      var rootCandidates;
      try {
        rootCandidates = await getRootCandidates(rootConfigModel.date);
      } catch (e) {
        showOkDialog('Server error',
            'There was an error connecting to the Trustchain server.\n\nPlease try again later.');
        return;
      }

      // Request the user to enter the confirmation code.
      final confCode = await requestConfirmationCode();
      if (confCode == null ||
          confCode.length < Constants.confirmationCodeMinimumLength) return;

      // Filter the root candidates w.r.t. the confirmation code.
      final matchingCandidates = rootCandidates.matchingCandidates(confCode);

      // If the confirmation code does not uniquely identify a root DID candidate, stop.
      if (matchingCandidates.length != 1) {
        showOkDialog('Invalid date/confirmation code',
            'The combination of root event date and confirmation code entered is not valid.\n\nPlease check and try again.');
        return;
      }
      var root = matchingCandidates.first;

      // Now that we have the unique root, get the timestamp via an HTTP request.
      var rootTimestamp;
      try {
        rootTimestamp = await getBlockTimestamp(root.blockHeight);
      } catch (e) {
        showOkDialog('Server error',
            'There was an error connecting to the Trustchain server.\n\nPlease try again later.');
        return;
      }

      // Confirm that the timestamp returned by the server falls within the correct date.
      if (!validate_timestamp(rootTimestamp.timestamp, rootConfigModel.date)) {
        final localizations = AppLocalizations.of(context)!;
        showOkDialog(
            'Invalid timestamp',
            'The server returned an invalid timestamp.\n\nPlease check the "' +
                localizations.trustchainEndpoint.replaceAll(':', '') +
                '" setting and try again.');
        return;
      }

      setState(() {
        rootConfigModel.confimationCode = confCode;
        rootConfigModel.root = root;
        rootConfigModel.timestamp = rootTimestamp.timestamp;
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

  void showOkDialog(String title, String content,
      [Icon? icon = null, double fontSize = 14]) async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              icon: icon,
              title: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Text(
                content,
                style: TextStyle(fontSize: fontSize),
              ),
              actions: [
                TextButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.pop(context))
              ],
            ));
  }
}
