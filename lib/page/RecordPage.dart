import 'package:flutter/material.dart';
import 'package:project_apraxia/controller/PromptController.dart';
import 'package:project_apraxia/interface/IWSDCalculator.dart';
import 'package:project_apraxia/model/Prompt.dart';
import 'package:project_apraxia/page/PromptsPage.dart';


class RecordPage extends StatefulWidget {
  final IWSDCalculator wsdCalculator;
  final String evaluationId;
  const RecordPage({Key key, @required this.wsdCalculator, @required this.evaluationId}) : super(key: key);

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  PromptController promptController = new PromptController();
  Future<List<Prompt>> promptsFuture;

  _RecordPageState() {
    promptsFuture = promptController.getEnabledPrompts();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: promptsFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return _buildErrorPage(snapshot.error.toString());
        } else if (snapshot.connectionState != ConnectionState.done) {
          return _buildPromptsLoading();
        } else {
          return PromptsPage(snapshot.data, wsdCalculator: widget.wsdCalculator, evaluationId: widget.evaluationId,);
        }
      },
    );
  }

  Widget _buildPromptsLoading() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            Container(
              padding: EdgeInsets.all(8.0),
              child: Text("Loading Prompts..."),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPage(error) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(error, style: TextStyle(color: Colors.red),),
            FlatButton.icon(
              icon: Icon(Icons.refresh),
              label: Text("Retry"),
              onPressed: (){
                setState(() {
                  promptsFuture = promptController.getPrompts();
                });
              },
            )
          ],
        ),
      ),
    );
  }
}
