import 'package:flutter/material.dart';
import '../../api/exam_api.dart';
import 'exam_model.dart';
import 'exam_attempt_model.dart';

class ExamViewModel extends ChangeNotifier {
  bool isLoadingExam = false;
  bool isSubmitting = false;

  ExamModel? _currentExam;
  ExamModel? get currentExam => _currentExam;

  ExamAttemptModel? _currentAttempt;
  ExamAttemptModel? get currentAttempt => _currentAttempt;

  List<ExamAttemptModel> _attempts = [];
  List<ExamAttemptModel> get attempts => _attempts;

  Map<String, String> _selectedAnswers = {};
  Map<String, String> get selectedAnswers => _selectedAnswers;

  // Ambil exam berdasarkan course
  Future<void> loadExam(String courseId) async {
    isLoadingExam = true;
    _selectedAnswers = {};
    _currentAttempt = null;
    notifyListeners();
    try {
      _currentExam = await ExamAPI().fetchExamByCourse(courseId);

      // ← tambah ini: fetch riwayat attempt sekalian
      if (_currentExam != null) {
        _attempts = await ExamAPI().fetchAttemptsByCourse(courseId);
      }

      print(
        '🟢 [ExamViewModel.loadExam] exam=${_currentExam?.examName}, attempts=${_attempts.length}, hasPassed=$hasPassed',
      );
    } catch (e, stack) {
      print('🔴 [ExamViewModel.loadExam] ERROR: $e');
      print('🔴 $stack');
      _currentExam = null;
    }
    isLoadingExam = false;
    notifyListeners();
  }

  // Pilih jawaban
  void selectAnswer(String questionId, String optionId) {
    _selectedAnswers[questionId] = optionId;
    notifyListeners();
  }

  // Cek apakah semua soal sudah dijawab
  bool get allAnswered {
    if (_currentExam?.questions == null) return false;
    return _currentExam!.questions!.every(
      (q) => _selectedAnswers.containsKey(q.id),
    );
  }

  // Submit exam
  Future<ExamAttemptModel?> startAndSubmit() async {
    if (_currentExam == null) return null;
    isSubmitting = true;
    notifyListeners();
    try {
      final attempt = await ExamAPI().startAttempt(_currentExam!.id!);
      _currentAttempt = await ExamAPI().submitAttempt(
        attemptId: attempt.id!,
        examId: _currentExam!.id!,
        answers: _selectedAnswers,
      );
      _attempts = await ExamAPI().fetchAttemptsByCourse(
        _currentExam!.courseId!,
      );
    } catch (e) {
      print('🔴 [ExamViewModel.startAndSubmit] ERROR: $e');
    }
    isSubmitting = false;
    notifyListeners();
    return _currentAttempt;
  }

  // Load riwayat attempt untuk course tertentu
  Future<void> loadAttempts(String courseId) async {
    try {
      _attempts = await ExamAPI().fetchAttemptsByCourse(courseId);
      notifyListeners();
    } catch (e) {
      print('🔴 [ExamViewModel.loadAttempts] ERROR: $e');
    }
  }

  // Cek apakah user sudah pernah lulus
  bool get hasPassed => _attempts.any((a) => a.isPassed == true);

  // Attempt terakhir
  ExamAttemptModel? get lastAttempt =>
      _attempts.isNotEmpty ? _attempts.first : null;

  void reset() {
    _currentExam = null;
    _currentAttempt = null;
    _selectedAnswers = {};
    _attempts = [];
    notifyListeners();
  }
}
