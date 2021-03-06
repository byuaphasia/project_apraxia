import 'package:flutter/services.dart';
import 'package:project_apraxia/interface/IWSDCalculator.dart';
import 'package:project_apraxia/model/Attempt.dart';

class LocalWSDCalculator extends IWSDCalculator {
  static const channel = const MethodChannel("wsdCalculator");

  @override
  Future<void> setAmbiance(String fileName, {String evalId: ""}) async {
    await channel.invokeMethod("calculateAmbiance", [fileName]);
  }

  @override
  Future<Attempt> addAttempt(String fileName, String word, int syllableCount, String evaluationId) async {
    return Attempt("", await channel.invokeMethod("calculateWSD", [fileName, syllableCount, evaluationId]));
  }

  @override
  Future<List<double>> getAmplitudes(String fileName) async {
    List<dynamic> amplitudes = await channel.invokeMethod("getAmplitude", [fileName]);
    return List<double>.from(amplitudes);
  }

  @override
  Future<void> updateAttempt(String evalId, String attemptId, bool active) async {}
}