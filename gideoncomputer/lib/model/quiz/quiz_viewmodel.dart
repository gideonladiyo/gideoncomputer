import 'package:flutter/material.dart';
import '../../api/quiz_api.dart';
import 'quiz_model.dart';
import 'quiz_attempt_model.dart';

class QuizViewModel extends ChangeNotifier {
  bool isLoadingQuiz = false;
  bool isSubmitting = false;

  QuizModel? _currentQuiz;
  QuizModel? get currentQuiz => _currentQuiz;

  QuizAttemptModel? _currentAttempt;
  QuizAttemptModel? get currentAttempt => _currentAttempt;

  List<QuizAttemptModel> _attempts = [];
  List<QuizAttemptModel> get attempts => _attempts;

  // Jawaban sementara user: {question_id: selected_option_id}
  Map<String, String> _selectedAnswers = {};
  Map<String, String> get selectedAnswers => _selectedAnswers;

  // Ambil quiz berdasarkan section
  Future<void> loadQuiz(String sectionId) async {
    isLoadingQuiz = true;
    _selectedAnswers = {};
    _currentAttempt = null;
    notifyListeners();
    try {
      _currentQuiz = await QuizAPI().fetchQuizBySection(sectionId);
    } catch (e) {
      print('🔴 [QuizViewModel.loadQuiz] ERROR: $e');
      _currentQuiz = null;
    }
    isLoadingQuiz = false;
    notifyListeners();
  }

  // Pilih jawaban
  void selectAnswer(String questionId, String optionId) {
    _selectedAnswers[questionId] = optionId;
    notifyListeners();
  }

  // Cek apakah semua soal sudah dijawab
  bool get allAnswered {
    if (_currentQuiz?.questions == null) return false;
    return _currentQuiz!.questions!.every(
      (q) => _selectedAnswers.containsKey(q.id),
    );
  }

  // Mulai attempt dan langsung submit
  Future<QuizAttemptModel?> startAndSubmit() async {
    if (_currentQuiz == null) return null;
    isSubmitting = true;
    notifyListeners();
    try {
      // Mulai attempt
      final attempt = await QuizAPI().startAttempt(_currentQuiz!.id!);

      // Submit jawaban
      _currentAttempt = await QuizAPI().submitAttempt(
        attemptId: attempt.id!,
        quizId: _currentQuiz!.id!,
        answers: _selectedAnswers,
      );

      // Refresh riwayat attempt
      _attempts = await QuizAPI().fetchAttemptsByQuiz(_currentQuiz!.id!);
    } catch (e) {
      print('🔴 [QuizViewModel.startAndSubmit] ERROR: $e');
    }
    isSubmitting = false;
    notifyListeners();
    return _currentAttempt;
  }

  // Load riwayat attempt untuk quiz tertentu
  Future<void> loadAttempts(String quizId) async {
    try {
      _attempts = await QuizAPI().fetchAttemptsByQuiz(quizId);
      notifyListeners();
    } catch (e) {
      print('🔴 [QuizViewModel.loadAttempts] ERROR: $e');
    }
  }

  void reset() {
    _currentQuiz = null;
    _currentAttempt = null;
    _selectedAnswers = {};
    _attempts = [];
    notifyListeners();
  }
}
