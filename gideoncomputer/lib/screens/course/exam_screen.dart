import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/assessment/assessment_viewmodel.dart';
import '../../model/course/enrolled_course_model.dart';
import 'quiz_result_screen.dart';
import 'success_course_screen.dart';

class ExamScreen extends StatefulWidget {
  final String courseId;
  final String courseName;
  final EnrolledCourseModel? enrolledCourse;

  const ExamScreen({
    super.key,
    required this.courseId,
    required this.courseName,
    this.enrolledCourse,
  });

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AssessmentViewModel>(
        context,
        listen: false,
      ).loadExam(widget.courseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Final Exam — ${widget.courseName}'),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7),
          child: CircleAvatar(
            backgroundColor: const Color.fromARGB(62, 158, 158, 158),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.chevron_left_outlined,
                color: Color(0xFFD32F2F),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<AssessmentViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.current == null) {
            return const Center(
              child: Text('Belum ada final exam untuk kursus ini.'),
            );
          }

          // Jika sudah pernah lulus, tampilkan info
          if (vm.hasPassed) {
            final last = vm.lastAttempt;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.emoji_events_rounded,
                      size: 80,
                      color: Color(0xFFD32F2F),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Kamu sudah lulus exam ini!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (last != null)
                      Text(
                        'Score terbaik: ${last.score}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                      ),
                      child: const Text('Kembali'),
                    ),
                  ],
                ),
              ),
            );
          }

          final questions = vm.current!.questions ?? [];
          if (questions.isEmpty) {
            return const Center(child: Text('Exam belum memiliki soal.'));
          }

          final question = questions[_currentIndex];
          final options = question.options ?? [];
          final selectedOptionId = vm.selectedAnswers[question.id];
          final total = questions.length;

          return Column(
            children: [
              // Progress bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Soal ${_currentIndex + 1} dari $total',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${vm.selectedAnswers.length}/$total dijawab',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD32F2F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_currentIndex + 1) / total,
                        minHeight: 6,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFFD32F2F),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          question.questionText ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...options.map((opt) {
                        final isSelected = selectedOptionId == opt.id;
                        return GestureDetector(
                          onTap: () => vm.selectAnswer(question.id!, opt.id!),
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFD32F2F)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFD32F2F)
                                    : Colors.grey[300]!,
                              ),
                            ),
                            child: Text(
                              opt.optionText ?? '',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // Navigasi + submit
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(30, 0, 0, 0),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _currentIndex > 0
                                ? () => setState(() => _currentIndex--)
                                : null,
                            child: const Text('Sebelumnya'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _currentIndex < total - 1
                              ? ElevatedButton(
                                  onPressed: () =>
                                      setState(() => _currentIndex++),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD32F2F),
                                  ),
                                  child: const Text('Selanjutnya'),
                                )
                              : ElevatedButton(
                                  onPressed: vm.allAnswered && !vm.isSubmitting
                                      ? () => _submit(vm)
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD32F2F),
                                  ),
                                  child: vm.isSubmitting
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Submit Exam'),
                                ),
                        ),
                      ],
                    ),
                    if (!vm.allAnswered && _currentIndex == total - 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Masih ada ${total - vm.selectedAnswers.length} soal belum dijawab',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submit(AssessmentViewModel vm) async {
    final result = await vm.startAndSubmit();
    if (!mounted) return;
    if (result != null) {
      final enrolled = widget.enrolledCourse;
      final nav = Navigator.of(context);

      nav.pushReplacement(
        MaterialPageRoute(
          builder: (_) => QuizResultScreen(
            score: result.score ?? 0,
            isPassed: result.isPassed ?? false,
            passingScore: vm.current?.passingScore ?? 80,
            quizName: vm.current?.assessmentName ?? 'Final Exam',
            isExam: true, // ← tandai ini exam
            onRetry: result.isPassed == true
                ? null
                : () {
                    nav.pop();
                    vm.loadExam(widget.courseId);
                  },
            onNextLabel: result.isPassed == true
                ? 'Lihat Certificate'
                : 'Lanjutkan',
            onNext: result.isPassed == true && enrolled != null
                ? () {
                    // Pop semua sampai root lalu push successCourse
                    nav.pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => SuccessCourseScreen(),
                        settings: RouteSettings(arguments: enrolled),
                      ),
                      (route) => route.isFirst,
                    );
                  }
                : null,
          ),
        ),
      );
    }
  }
}
