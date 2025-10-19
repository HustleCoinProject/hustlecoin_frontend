import 'package:flutter/foundation.dart';

@immutable
class QuizResult {
  final String quizId;
  final int answerIndex;

  const QuizResult({required this.quizId, required this.answerIndex});

  // toJson
  Map<String, dynamic> toJson() {
    return {'quizId': quizId, 'answerIndex': answerIndex};
  }
}

// Hacky global variable to store quiz results
QuizResult? globalQuizResult;
