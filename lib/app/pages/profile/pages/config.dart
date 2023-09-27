import 'package:credible/app/pages/profile/blocs/config.dart';
import 'package:credible/app/pages/profile/blocs/profile.dart';
import 'package:credible/app/pages/profile/models/config.dart';
import 'package:credible/app/pages/profile/models/profile.dart';
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
  final ValueNotifier<bool> _rootEventDateIsSet = ValueNotifier<bool>(false);
  // double _datePickerHeight = 200;

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
            color: Colors.white,
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
                        // height: _datePickerHeight,
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
                            minimumDate: DateTime(2021, 2, 1),
                            maximumDate:
                                DateTime.now().add(const Duration(days: 365)),
                            dateOrder: DatePickerDateOrder.dmy,
                            backgroundColor: Colors.white,
                            onDateTimeChanged: (DateTime newDateTime) {
                              // Do nothing till the setRootEventDate is pressed.
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
                        // TODO:
                        // - add a warning above the Set & Change root event date buttons
                        // - include a call to the server to retrieve root DID candidates for the given date, etc.
                        setState(() {
                          _rootEventDateIsSet.value =
                              !_rootEventDateIsSet.value;
                          // _datePickerHeight = 30;
                        });
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
}
