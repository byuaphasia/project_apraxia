class Attempt {
  String attemptId;
  String evaluationId;
  String word;
  double wsd;
  double duration;
  bool active;
  String dateCreated;


  Attempt(this.attemptId, this.wsd);

  Attempt.fromMap(Map<String, dynamic> map) {
    this.attemptId = map["attemptId"];
    this.evaluationId = map["evaluationId"];
    this.word = map["word"];
    this.wsd = map["wsd"];
    this.duration = map["duration"];
    this.active = map["active"];
    this.dateCreated = map["dateCreated"];
  }
}