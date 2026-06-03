import 'package:flutter/material.dart';
import '../../api/assessment_api.dart';
import 'assessment_model.dart';
import 'assessment_attempt_model.dart';

class AssessmentViewModel extends ChangeNotifier {
  bool isLoading = false;
  bool isSubmitting = false;

  AssessmentModel? _current;
  AssessmentModel? get current => _current;

  AssessmentAttemptModel? _currentAttempt;
  AssessmentAttemptModel? get currentAttempt => _currentAttempt;

  List<AssessmentAttemptModel> _attempts = [];
  List<AssessmentAttemptModel> get attempts => _attempts;

  Map<String, String> _selectedAnswers = {};
  Map<String, String> get selectedAnswers => _selectedAnswers;

  // Load quiz berdasarkan section_id
  Future<void> loadQuiz(String sectionId) async {
    isLoading = true;
    _selectedAnswers = {};
    _currentAttempt = null;
    notifyListeners();
    try {
      _current = await AssessmentAPI().fetchQuizBySection(sectionId);
      if (_current != null) {
        _attempts = await AssessmentAPI().fetchAttempts(_current!.id!);
      }
    } catch (e) {
      print('🔴 [AssessmentViewModel.loadQuiz] ERROR: $e');
      _current = null;
    }
    isLoading = false;
    notifyListeners();
  }

  // Load exam berdasarkan course_id
  Future<void> loadExam(String courseId) async {
    isLoading = true;
    _selectedAnswers = {};
    _currentAttempt = null;
    notifyListeners();
    try {
      _current = await AssessmentAPI().fetchExamByCourse(courseId);
      if (_current != null) {
        _attempts = await AssessmentAPI().fetchAttempts(_current!.id!);
      }
      print(
        '🟢 [AssessmentViewModel.loadExam] exam=${_current?.assessmentName}, attempts=${_attempts.length}, hasPassed=$hasPassed',
      );
    } catch (e, stack) {
      print('🔴 [AssessmentViewModel.loadExam] ERROR: $e');
      print('🔴 $stack');
      _current = null;
    }
    isLoading = false;
    notifyListeners();
  }

  void selectAnswer(String questionId, String optionId) {
    _selectedAnswers[questionId] = optionId;
    notifyListeners();
  }

  bool get allAnswered {
    if (_current?.questions == null) return false;
    return _current!.questions!.every(
      (q) => _selectedAnswers.containsKey(q.id),
    );
  }

  Future<AssessmentAttemptModel?> startAndSubmit() async {
    if (_current == null) return null;
    isSubmitting = true;
    notifyListeners();
    try {
      final attempt = await AssessmentAPI().startAttempt(_current!.id!);
      _currentAttempt = await AssessmentAPI().submitAttempt(
        attemptId: attempt.id!,
        assessmentId: _current!.id!,
        answers: _selectedAnswers,
      );
      _attempts = await AssessmentAPI().fetchAttempts(_current!.id!);
    } catch (e) {
      print('🔴 [AssessmentViewModel.startAndSubmit] ERROR: $e');
    }
    isSubmitting = false;
    notifyListeners();
    return _currentAttempt;
  }

  bool get hasPassed => _attempts.any((a) => a.isPassed == true);

  AssessmentAttemptModel? get lastAttempt =>
      _attempts.isNotEmpty ? _attempts.first : null;

  void reset() {
    _current = null;
    _currentAttempt = null;
    _selectedAnswers = {};
    _attempts = [];
    notifyListeners();
  }
}
