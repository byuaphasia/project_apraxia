import 'package:flutter/material.dart';
import 'package:project_apraxia/model/SurveyFormFields.dart';
import 'package:project_apraxia/page/AmbiancePage.dart';
import 'package:project_apraxia/controller/HttpConnector.dart';
import 'package:project_apraxia/interface/IWSDCalculator.dart';
import 'package:project_apraxia/controller/FormValidator.dart';

import 'package:project_apraxia/widget/ErrorDialog.dart';

class SurveyForm extends StatefulWidget {
  static GlobalKey<FormState> _formKey = new GlobalKey();
  final IWSDCalculator wsdCalculator;

  SurveyForm({@required this.wsdCalculator, Key key}) : super(key: key);

  @override
  _SurveyFormState createState() => _SurveyFormState();
}

class _SurveyFormState extends State<SurveyForm> {
  final SurveyFormFields fields = new SurveyFormFields();
  List<String> _genderOptions = [
    'Female',
    'Male',
    'Other',
    'Prefer not to disclose'
  ];
  bool _doNotDiscloseAge = false;
  bool _aphasia = false;
  bool _apraxia = false;
  bool _dysarthria = false;
  bool _other = false;
  String _otherImpression;
  bool _none = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: SurveyForm._formKey,
      child: Expanded(
        child: ListView(
          children: <Widget>[
            ListTile(
              leading: Text("Patient gender:"),
              title: DropdownButton<String>(
                  hint: Text("Please select an option"),
                  items: _genderOptions.map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value),
                    );
                  }).toList(),
                  value: fields.gender,
                  onChanged: (String value) {
                    setState(() {
                      fields.gender = value;
                    });
                  }),
            ),
            ListTile(
              leading: Text("Patient age:"),
              title: TextFormField(
                  initialValue: fields.age,
                  keyboardType: TextInputType.numberWithOptions(),
                  validator: (String age) {
                    if (!_doNotDiscloseAge) {
                      return FormValidator.isValidAge(age);
                    }
                    return null;
                  },
                  onChanged: (String value) {
                    setState(() {
                      fields.age = value;
                    });
                  },
                  onSaved: (String value) {
                    fields.age = value;
                  }),
            ),
            ListTile(
              title: Text("Patient does not wish to disclose age:"),
              trailing: Checkbox(
                value: _doNotDiscloseAge,
                onChanged: (bool value) {
                  setState(() {
                    _doNotDiscloseAge = value;
                    if (!value) {
                      fields.age = "";
                    }
                  });
                },
              ),
            ),
            ListTile(
                leading: Text("Clinical impression (check all that apply):")),
            ListTile(
              title: Text("Aphasia"),
              trailing: Checkbox(
                value: _aphasia,
                onChanged: (bool value) {
                  setState(() {
                    _aphasia = value;
                    if (value) {
                      _none = false;
                    }
                  });
                },
              ),
            ),
            ListTile(
              title: Text("Apraxia"),
              trailing: Checkbox(
                value: _apraxia,
                onChanged: (bool value) {
                  setState(() {
                    _apraxia = value;
                    if (value) {
                      _none = false;
                    }
                  });
                },
              ),
            ),
            ListTile(
              title: Text("Dysarthria"),
              trailing: Checkbox(
                value: _dysarthria,
                onChanged: (bool value) {
                  setState(() {
                    _dysarthria = value;
                    if (value) {
                      _none = false;
                    }
                  });
                },
              ),
            ),
            ListTile(
                title: Text("Other (specify)"),
                trailing: Checkbox(
                  value: _other,
                  onChanged: (bool value) {
                    setState(() {
                      _other = value;
                      if (value) {
                        _none = false;
                      }
                    });
                  },
                )),
            !_other
                ? Container()
                : ListTile(
                    title: TextFormField(
                      initialValue: _otherImpression,
                      onChanged: (String value) {
                        setState(() {
                          _otherImpression = value;
                        });
                      },
                      validator: (String s) {
                        return FormValidator.isValidImpression(s);
                      },
                    ),
                  ),
            ListTile(
              title: Text("None"),
              trailing: Checkbox(
                value: _none,
                onChanged: (bool value) {
                  setState(() {
                    if (value) {
                      _none = value;
                      _dysarthria = false;
                      _aphasia = false;
                      _apraxia = false;
                      _other = false;
                    }
                  });
                },
              ),
            ),
            ButtonBar(
              children: <Widget>[
                RaisedButton(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Submit"),
                  ),
                  onPressed: () => this.submit(context),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void submit(BuildContext context) async {
    if (SurveyForm._formKey.currentState.validate()) {
      SurveyForm._formKey.currentState.save();
      String gender = fields.gender.toLowerCase();
      if (fields.gender == "Prefer not to disclose") {
        gender = "no answer";
      }

      if (_doNotDiscloseAge) {
        fields.age = "no answer";
      }
      fields.impression = "";
      if (!_none) {
        if (_apraxia) {
          fields.impression += "apraxia,";
        }
        if (_aphasia) {
          fields.impression += "aphasia,";
        }
        if (_dysarthria) {
          fields.impression += "dysarthria,";
        }
        if (_other) {
          fields.impression += _otherImpression;
        }
      }
      HttpConnector connector = new HttpConnector.instance();

      try {
        String evalId = await connector.createEvaluation(
            fields.age, gender, fields.impression);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => AmbiancePage(
                      wsdCalculator: widget.wsdCalculator,
                      evalId: evalId,
                    )));
      } on ServerConnectionException {
        ErrorDialog errorDialog = new ErrorDialog(context);
        errorDialog.show("Error Connecting to Server",
            "The server is currently down.");
      } on InternalServerException {
        ErrorDialog errorDialog = new ErrorDialog(context);
        errorDialog.show("Error Connecting to Server",
            "An unexpected server error occurred.");
      }
    }
  }
}
