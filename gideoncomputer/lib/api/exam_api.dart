import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/exam/exam_model.dart';
import '../model/exam/exam_attempt_model.dart';

class ExamAPI {
  final supabase = Supabase.instance.client;

  // Ambil exam beserta soal dan pilihan jawaban berdasarkan course
  Future<ExamModel?> fetchExamByCourse(String courseId) async {
    final response = await supabase
        .from('exams')
        .select('''
          *,
          questions (
            *,
            question_options (*)
          )
        ''')
        .eq('course_id', courseId)
        .maybeSingle(); // nullable, course mungkin belum punya exam

    if (response == null) return null;
    return ExamModel.fromJson(response);
  }

  // Mulai attempt exam baru
  Future<ExamAttemptModel> startAttempt(String examId) async {
    final user = supabase.auth.currentUser;
    final response = await supabase
        .from('exam_attempts')
        .insert({
          'user_id': user!.id,
          'exam_id': examId,
          'started_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    return ExamAttemptModel.fromJson(response);
  }

  // Submit jawaban exam dan hitung score
  Future<ExamAttemptModel> submitAttempt({
    required String attemptId,
    required String examId,
    required Map<String, String> answers, // {question_id: selected_option_id}
  }) async {
    // Ambil semua option yang correct
    final correctOptions = await supabase
        .from('question_options')
        .select('id, question_id')
        .eq('is_correct', true)
        .inFilter('question_id', answers.keys.toList());

    final correctMap = {
      for (var o in correctOptions as List) o['question_id']: o['id'],
    };

    // Simpan tiap jawaban
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

    await supabase.from('exam_answers').insert(answerRows);

    // Hitung score
    final total = answers.length;
    final score = total == 0 ? 0 : ((correct / total) * 100).round();

    final exam = await supabase
        .from('exams')
        .select('passing_score')
        .eq('id', examId)
        .single();

    final isPassed = score >= (exam['passing_score'] as int);

    final updated = await supabase
        .from('exam_attempts')
        .update({
          'score': score,
          'is_passed': isPassed,
          'submitted_at': DateTime.now().toIso8601String(),
        })
        .eq('id', attemptId)
        .select()
        .single();

    // Kalau lulus, otomatis generate certificate
    if (isPassed) {
      await _issueCertificate(examId: examId, attemptId: attemptId);
    }

    return ExamAttemptModel.fromJson(updated);
  }

  // Generate certificate otomatis setelah lulus exam
  Future<void> _issueCertificate({
    required String examId,
    required String attemptId,
  }) async {
    final user = supabase.auth.currentUser;

    // Ambil course_id dari exam
    final exam = await supabase
        .from('exams')
        .select('course_id')
        .eq('id', examId)
        .single();

    // Cek apakah certificate sudah pernah dibuat
    final existing = await supabase
        .from('certificates')
        .select('id')
        .eq('user_id', user!.id)
        .eq('course_id', exam['course_id'])
        .maybeSingle();

    if (existing != null) return; // sudah ada, skip

    // Generate certificate number: CERT-{timestamp}-{userId 8 char}
    final certNumber =
        'CERT-${DateTime.now().millisecondsSinceEpoch}-${user.id.substring(0, 8).toUpperCase()}';

    await supabase.from('certificates').insert({
      'user_id': user.id,
      'course_id': exam['course_id'],
      'exam_attempt_id': attemptId,
      'certificate_number': certNumber,
    });
  }

  // Ambil riwayat attempt exam user untuk course tertentu
  Future<List<ExamAttemptModel>> fetchAttemptsByCourse(String courseId) async {
    final user = supabase.auth.currentUser;

    final exam = await supabase
        .from('exams')
        .select('id')
        .eq('course_id', courseId)
        .maybeSingle();

    if (exam == null) return [];

    final response = await supabase
        .from('exam_attempts')
        .select()
        .eq('user_id', user!.id)
        .eq('exam_id', exam['id'])
        .order('started_at', ascending: false);

    return (response as List).map((e) => ExamAttemptModel.fromJson(e)).toList();
  }
}
