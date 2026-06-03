import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/assessment/assessment_model.dart';
import '../model/assessment/assessment_attempt_model.dart';
import '../model/assessment/assessment_answer_model.dart';

class AssessmentAPI {
  final supabase = Supabase.instance.client;

  // Ambil quiz (type='quiz') berdasarkan section_id
  Future<AssessmentModel?> fetchQuizBySection(String sectionId) async {
    final response = await supabase
        .from('assessments')
        .select('''
          *,
          questions (
            *,
            question_options (*)
          )
        ''')
        .eq('assessment_type', 'quiz')
        .eq('section_id', sectionId)
        .maybeSingle();

    if (response == null) return null;
    return AssessmentModel.fromJson(response);
  }

  // Ambil exam (type='exam') berdasarkan course_id
  Future<AssessmentModel?> fetchExamByCourse(String courseId) async {
    final response = await supabase
        .from('assessments')
        .select('''
          *,
          questions (
            *,
            question_options (*)
          )
        ''')
        .eq('assessment_type', 'exam')
        .eq('course_id', courseId)
        .maybeSingle();

    if (response == null) return null;
    return AssessmentModel.fromJson(response);
  }

  // Mulai attempt baru
  Future<AssessmentAttemptModel> startAttempt(String assessmentId) async {
    final user = supabase.auth.currentUser;
    final response = await supabase
        .from('assessment_attempts')
        .insert({
          'user_id': user!.id,
          'assessment_id': assessmentId,
          'started_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    return AssessmentAttemptModel.fromJson(response);
  }

  // Submit jawaban dan hitung score
  Future<AssessmentAttemptModel> submitAttempt({
    required String attemptId,
    required String assessmentId,
    required Map<String, String> answers, // {question_id: selected_option_id}
  }) async {
    // Ambil semua opsi yang benar
    final correctOptions = await supabase
        .from('question_options')
        .select('id, question_id')
        .eq('is_correct', true)
        .inFilter('question_id', answers.keys.toList());

    final correctMap = {
      for (var o in correctOptions as List) o['question_id']: o['id'],
    };

    // Hitung skor & simpan jawaban
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

    await supabase.from('assessment_answers').insert(answerRows);

    final total = answers.length;
    final score = total == 0 ? 0 : ((correct / total) * 100).round();

    // Ambil passing_score dari assessment
    final assessment = await supabase
        .from('assessments')
        .select('passing_score, assessment_type, course_id')
        .eq('id', assessmentId)
        .single();

    final isPassed = score >= (assessment['passing_score'] as int);

    final updated = await supabase
        .from('assessment_attempts')
        .update({
          'score': score,
          'is_passed': isPassed,
          'submitted_at': DateTime.now().toIso8601String(),
        })
        .eq('id', attemptId)
        .select()
        .single();

    // Kalau exam dan lulus → issue certificate
    if (isPassed && assessment['assessment_type'] == 'exam') {
      await _issueCertificate(
        courseId: assessment['course_id'],
        attemptId: attemptId,
      );
    }

    return AssessmentAttemptModel.fromJson(updated);
  }

  // Ambil riwayat attempt untuk assessment tertentu
  Future<List<AssessmentAttemptModel>> fetchAttempts(
      String assessmentId) async {
    final user = supabase.auth.currentUser;
    final response = await supabase
        .from('assessment_attempts')
        .select()
        .eq('user_id', user!.id)
        .eq('assessment_id', assessmentId)
        .order('started_at', ascending: false);

    return (response as List)
        .map((e) => AssessmentAttemptModel.fromJson(e))
        .toList();
  }

  // Generate certificate setelah lulus exam
  Future<void> _issueCertificate({
    required String courseId,
    required String attemptId,
  }) async {
    final user = supabase.auth.currentUser;

    // Cek kalau sudah pernah dapat certificate
    final existing = await supabase
        .from('certificates')
        .select('id')
        .eq('user_id', user!.id)
        .eq('course_id', courseId)
        .maybeSingle();

    if (existing != null) return;

    final certNumber =
        'CERT-${DateTime.now().millisecondsSinceEpoch}-${user.id.substring(0, 8).toUpperCase()}';

    await supabase.from('certificates').insert({
      'user_id': user.id,
      'course_id': courseId,
      'attempt_id': attemptId,
      'certificate_number': certNumber,
    });
  }
}
