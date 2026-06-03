import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/quiz/quiz_model.dart';
import '../model/quiz/quiz_attempt_model.dart';
import '../model/quiz/quiz_answer_model.dart';

class QuizAPI {
  final supabase = Supabase.instance.client;

  // Ambil quiz beserta soal dan pilihan jawaban berdasarkan section
  Future<QuizModel> fetchQuizBySection(String sectionId) async {
    final response = await supabase
        .from('quizzes')
        .select('''
          *,
          questions (
            *,
            question_options (*)
          )
        ''')
        .eq('section_id', sectionId)
        .single();

    return QuizModel.fromJson(response);
  }

  // Mulai attempt baru, return attempt id
  Future<QuizAttemptModel> startAttempt(String quizId) async {
    final user = supabase.auth.currentUser;
    final response = await supabase
        .from('quiz_attempts')
        .insert({
          'user_id': user!.id,
          'quiz_id': quizId,
          'started_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    return QuizAttemptModel.fromJson(response);
  }

  // Submit jawaban dan hitung score
  Future<QuizAttemptModel> submitAttempt({
    required String attemptId,
    required String quizId,
    required Map<String, String> answers, // {question_id: selected_option_id}
  }) async {
    // Ambil semua option yang correct untuk quiz ini
    final correctOptions = await supabase
        .from('question_options')
        .select('id, question_id')
        .eq('is_correct', true)
        .inFilter('question_id', answers.keys.toList());

    // Buat map {question_id: correct_option_id}
    final correctMap = {
      for (var o in correctOptions as List) o['question_id']: o['id'],
    };

    // Hitung jawaban benar dan simpan tiap jawaban
    int correct = 0;
    final answerRows = answers.entries.map((e) {
      final isCorrect = correctMap[e.key] == e.value;
      if (isCorrect) correct++;
      return {
        'attempt_id': attemptId,
        'question_id': e.key,
        'selected_option_id': e.value,
        'is_correct': isCorrect,
      };
    }).toList();

    await supabase.from('quiz_answers').insert(answerRows);

    // Hitung score dan update attempt
    final total = answers.length;
    final score = total == 0 ? 0 : ((correct / total) * 100).round();

    // Ambil passing score quiz
    final quiz = await supabase
        .from('quizzes')
        .select('passing_score')
        .eq('id', quizId)
        .single();

    final isPassed = score >= (quiz['passing_score'] as int);

    final updated = await supabase
        .from('quiz_attempts')
        .update({
          'score': score,
          'is_passed': isPassed,
          'submitted_at': DateTime.now().toIso8601String(),
        })
        .eq('id', attemptId)
        .select()
        .single();

    return QuizAttemptModel.fromJson(updated);
  }

  // Ambil riwayat attempt user untuk quiz tertentu
  Future<List<QuizAttemptModel>> fetchAttemptsByQuiz(String quizId) async {
    final user = supabase.auth.currentUser;
    final response = await supabase
        .from('quiz_attempts')
        .select()
        .eq('user_id', user!.id)
        .eq('quiz_id', quizId)
        .order('started_at', ascending: false);

    return (response as List).map((e) => QuizAttemptModel.fromJson(e)).toList();
  }
}
