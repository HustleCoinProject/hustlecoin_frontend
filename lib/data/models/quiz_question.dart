import 'package:flutter/foundation.dart';

@immutable
class QuizQuestion {
  final String quizId;
  final String question;
  final List<String> options;

  const QuizQuestion({
    required this.quizId,
    required this.question,
    required this.options,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      quizId: json['quizId'],
      question: json['question'],
      options: List<String>.from(json['options']),
    );
  }
}
