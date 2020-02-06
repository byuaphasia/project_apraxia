import 'package:flutter/material.dart';
import 'package:project_apraxia/controller/HttpConnector.dart';
import 'package:project_apraxia/controller/LocalWSDCalculator.dart';
import 'package:project_apraxia/controller/RemoteWSDCalculator.dart';
import 'package:project_apraxia/page/AmbiancePage.dart';
import 'package:project_apraxia/page/WaiverPage.dart';
import 'package:project_apraxia/widget/ErrorDialog.dart';

class SelectWaiverPage extends StatefulWidget {
  SelectWaiverPage({Key key}) : super(key: key);

  @override
  _SelectWaiverPageState createState() => _SelectWaiverPageState();
}

class _SelectWaiverPageState extends State<SelectWaiverPage> {
  bool _waiver = true;
  List<dynamic> _patients = new List<dynamic>(0);
  bool _newPatient = true;
  int _oldPatientSelected = -1;
  String _patientName = '';
  String _patientEmail = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Waiver"),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            child: Container(),
            padding: EdgeInsets.only(top: 16.0),
          ),
          ListTile(
            title: Text('Skip HIPAA waiver and use basic processing', style: Theme.of(context).textTheme.title),
            leading: Radio(
              value: false,
              groupValue: _waiver,
              onChanged: (bool value) {
                setState(() {
                  _waiver = value;
                  _newPatient = false;
                  _oldPatientSelected = -1;
                });
              },
            ),
          ),
          ListTile(
            title: Text('Select or sign waiver and use better processing', style: Theme.of(context).textTheme.title),
            leading: Radio(
              value: true,
              groupValue: _waiver,
              onChanged: (bool value) {
                setState(() { _waiver = value; });
              },
            ),
          ),
          _waiver ? Padding(
            padding: EdgeInsets.only(left: 32.0, top: 8.0, right: 32.0),
            child: Column(
              children: <Widget>[
                ListTile(
                  title: const Text('New patient'),
                  leading: Radio(
                    value: true,
                    groupValue: _newPatient,
                    onChanged: (bool value) {
                      setState(() {
                        _newPatient = value;
                        _oldPatientSelected = -1;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Select a waiver from patients on file'),
                  leading: Radio(
                    value: false,
                    groupValue: _newPatient,
                    onChanged: (bool value) {
                      setState(() { _newPatient = value; });
                    },
                  ),
                ),
                _newPatient ? Container() :
                Column(
                  children: <Widget>[
                    ListTile(
                        title: TextFormField(
                          initialValue: _patientName,
                          decoration: InputDecoration(labelText: "Patient Name"),
                          onChanged: (String name) {
                            _patientName = name;
                          },
                        )
                    ),
                    ListTile(
                        title: TextFormField(
                          initialValue: _patientEmail,
                          decoration: InputDecoration(labelText: "Patient Email"),
                          onChanged: (String email) {
                            _patientEmail = email;
                          },
                        )
                    ),
                    RaisedButton(
                        child: const Text("Search"),
                        onPressed: () async {
                          var tmp = await loadPatients(_patientName, _patientEmail);
                          if (tmp != null) {
                            if (tmp.length > 0) {
                              setState(() {
                                _patients = tmp;
                              });
                            }
                            else {
                              ErrorDialog dialog = new ErrorDialog(context);
                              dialog.show("No waivers found",
                                  "There are no waivers on file for this name and email address. Please try another.");
                            }
                          }
                        }
                    ),
                    (_patients.length > 0) ?
                    ListTile(
                      title: Text('Name: ' + _patients[0]['subjectName'] + '\nEmail: ' + _patients[0]['subjectEmail']),
                      leading: Radio(
                        value: 0,
                        groupValue: _oldPatientSelected,
                        onChanged: (int value) {
                          setState(() {
                            _oldPatientSelected = value;
                          });
                        },
                      ),
                    ) : Container()
                  ],
                )
              ],
            )
          ) : Container(),
          Align(
            alignment: Alignment.bottomCenter,
            child: ButtonBar(
              children: <Widget>[
                _waiver ? Container() :
                RaisedButton(
                  child: Text("Skip Waiver - Basic Processing"),
                  onPressed: () => _startLocalTest(context),
                ),
                (_waiver && _newPatient) ?
                RaisedButton(
                  child: Text("Sign New Waiver"),
                  onPressed: () => _goToWaiverPage(context),
                ) : Container(),
                (_waiver && !_newPatient && _oldPatientSelected != -1) ?
                RaisedButton(
                  child: Text("Use This Waiver"),
                  onPressed: () => _startRemoteTest(context),
                ) : Container(),
              ],
              alignment: MainAxisAlignment.center,
            )
          )
        ],
      )
    );
  }

  Future<List<dynamic>> loadPatients(String subjectName, String subjectEmail) async {
    HttpConnector connector = new HttpConnector.instance();
    try {
      List<dynamic> result = await connector.getWaiversOnFile(
          subjectName.trim(), subjectEmail.trim().toLowerCase());
      return result;
    } on ServerConnectionException catch (e) {
      ErrorDialog dialog = new ErrorDialog(context);
      dialog.show('Error Contacting Server', e.message);
    } on InternalServerException catch (e) {
      ErrorDialog dialog = new ErrorDialog(context);
      dialog.show('Internal Server Error', e.message);
    }
    return null;
  }

  void _startLocalTest(BuildContext context) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return AmbiancePage(
        wsdCalculator: new LocalWSDCalculator(),
      );
    }));
  }

  void _goToWaiverPage(BuildContext context) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return WaiverPage();
    }));
  }

  void _startRemoteTest(BuildContext context) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return AmbiancePage(
        wsdCalculator: new RemoteWSDCalculator(),
      );
    }));
  }

}