import 'package:flutter/material.dart';
import 'package:flutter_demo_model_training/processor.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Processor processor = Processor();
  String _message = "Press 'Start Training' to begin.";
  late Interpreter _interpreter;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    _interpreter = await processor.createModel();
    processor.compileModel(_interpreter);
  }

  Future<void> _startTraining() async {
    setState(() {
      _message = "Loading training data...";
    });
    var trainingData = await processor.loadTrainingData();
    setState(() {
      _message = "Training started...";
    });
    await processor.trainModel(_interpreter, trainingData);
    setState(() {
      _message = "Training complete.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Model Training'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_message),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startTraining,
              child: Text('Start Training'),
            ),
          ],
        ),
      ),
    );
  }
}
