import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/assessment/assessment_viewmodel.dart';
import 'quiz_result_screen.dart';
import 'package:gideoncomputer/api/course_api.dart';

class QuizScreen extends StatefulWidget {
  final String sectionId;
  final String sectionName;
  final String? enrollmentId; // ← tambah
  final String? quizMaterialId; // ← tambah, id material type 'quiz'
  final VoidCallback? onCompleted;
  final bool isLastMaterial;

  const QuizScreen({
    super.key,
    required this.sectionId,
    required this.sectionName,
    this.enrollmentId,
    this.quizMaterialId,
    this.onCompleted,
    this.isLastMaterial = false,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AssessmentViewModel>(
        context,
        listen: false,
      ).loadQuiz(widget.sectionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sectionName),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7),
          child: CircleAvatar(
            backgroundColor: const Color.fromARGB(62, 158, 158, 158),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.chevron_left_outlined,
                color: Color(0xFF126E64),
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
              child: Text('Belum ada quiz untuk section ini.'),
            );
          }

          final questions = vm.current!.questions ?? [];
          if (questions.isEmpty) {
            return const Center(child: Text('Quiz tidak memiliki soal.'));
          }

          final question = questions[_currentIndex];
          final options = question.options ?? [];
          final selectedOptionId = vm.selectedAnswers[question.id];
          final total = questions.length;

          return Column(
            children: [
              // Progress bar soal
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
                            color: Color(0xFF126E64),
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
                          Color(0xFF126E64),
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
                      // Teks soal
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF6F5),
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

                      // Pilihan jawaban
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
                                  ? const Color(0xFF126E64)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF126E64)
                                    : Colors.grey[300]!,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
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

              // Navigasi soal + tombol submit
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
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF126E64),
                              side: const BorderSide(color: Color(0xFF126E64)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Sebelumnya',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _currentIndex < total - 1
                              ? ElevatedButton(
                                  onPressed: () =>
                                      setState(() => _currentIndex++),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF126E64),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Selanjutnya',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: vm.allAnswered && !vm.isSubmitting
                                      ? () => _submit(vm)
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF126E64),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
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
                                      : const Text(
                                          'Submit',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
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

    if (widget.enrollmentId != null && widget.quizMaterialId != null) {
      try {
        await CourseAPI().updateCourseProgress(
          widget.enrollmentId!,
          widget.quizMaterialId!,
        );
      } catch (e) {
        print('🔴 [QuizScreen] mark quiz complete error: $e');
      }
    }

    if (!mounted) return;

    if (result != null) {
      final nav = Navigator.of(context);
      final onCompleted = widget.onCompleted;
      final isLast = widget.isLastMaterial;

      nav.pushReplacement(
        MaterialPageRoute(
          builder: (_) => QuizResultScreen(
            score: result.score ?? 0,
            isPassed: result.isPassed ?? false,
            passingScore: vm.current?.passingScore ?? 70,
            quizName: vm.current?.assessmentName ?? 'Quiz',
            onRetry: () {
              nav.pop();
              vm.loadQuiz(widget.sectionId);
            },
            // Kalau quiz terakhir → label "Lihat Final Exam", kalau tidak → "Lanjutkan"
            onNextLabel: isLast ? 'Lihat Final Exam' : 'Lanjutkan',
            onNext: () {
              nav.pop();
              onCompleted?.call();
            },
          ),
        ),
      );
    }
  }
}
