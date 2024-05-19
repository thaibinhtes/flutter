import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';

class Processor {
  /// fake 4 ảnh để train
  /// convert sang định dạng Tensor
  Future<List<Map<String, dynamic>>> loadTrainingData() async {
    await copyAsset('img1.jpeg');
    await copyAsset('img2.jpeg');
    await copyAsset('img3.jpeg');
    await copyAsset('img4.jpeg');
    final directory = await getApplicationDocumentsDirectory();
    final dataDir = Directory('${directory.path}/training_data');
    final images = dataDir
        .listSync()
        .where((item) => item.path.endsWith('.jpeg'))
        .toList();

    List<Map<String, dynamic>> trainingData = [];
    for (var image in images) {
      var tensorBuffer = TensorImage.fromFile(File(image.path));
      trainingData.add({'image': tensorBuffer, 'label': 0});
    }
    return trainingData;
  }

  Future<Interpreter> createModel() async {
    final modelFile = await copyModelToLocal();
    var interpreterOptions = InterpreterOptions();
    return Interpreter.fromFile(modelFile, options: interpreterOptions);
  }

  void compileModel(Interpreter interpreter) {}

  ///
  /// Training
  /// cần đọc tài liệu của tensorflow để update các trọng số, dữ liệu đầu vào (size ảnh...)
  Future<void> trainModel(
      Interpreter interpreter, List<Map<String, dynamic>> trainingData) async {
    for (var epoch = 0; epoch < 3; epoch++) {
      for (var data in trainingData) {
        var input = data['image'].buffer;
        var label = data['label'];

        interpreter.run(input, label);
      }
    }
  }

  /// Copy pre-trained model vào internal storage
  ///
  Future<File> copyModelToLocal() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    String modelPath = '$appDocPath/model.tflite';
    File modelFile = File(modelPath);

    if (!modelFile.existsSync()) {
      ByteData data = await rootBundle.load('assets/model.tflite');
      List<int> bytes = data.buffer.asUint8List();
      await modelFile.writeAsBytes(bytes);
    }

    return modelFile;
  }

  /// Copy assets
  /// giả lập 2 ảnh chó, 2 ảnh mèo để train
  Future<File> copyAsset(String img) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    String imgPath = '$appDocPath/training_data/$img';
    File imgFile = File(imgPath);
    await imgFile.create(recursive: true);
    ByteData data = await rootBundle.load('assets/training_data/$img');
    List<int> bytes = data.buffer.asUint8List();
    await imgFile.writeAsBytes(bytes);
    return imgFile;
  }
}
