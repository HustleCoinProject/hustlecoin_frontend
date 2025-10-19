import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/quiz_question.dart';
import 'foundational_providers.dart';
import 'user_provider.dart';

final quizQuestionProvider = FutureProvider.autoDispose<QuizQuestion>((
  ref,
) async {
  // Ensure the user is logged in before fetching
  final user = ref.watch(userControllerProvider).value;
  if (user == null) {
    throw Exception("User must be logged in to fetch a quiz question.");
  }
  return ref.read(apiRepositoryProvider).fetchQuizQuestion();
});
