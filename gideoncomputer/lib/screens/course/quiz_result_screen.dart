import 'package:flutter/material.dart';

// tambah parameter isExam
class QuizResultScreen extends StatelessWidget {
  final int score;
  final bool isPassed;
  final int passingScore;
  final String quizName;
  final VoidCallback? onRetry;
  final VoidCallback? onNext;
  final String onNextLabel;
  final bool isExam; // ← tambah

  const QuizResultScreen({
    super.key,
    required this.score,
    required this.isPassed,
    required this.passingScore,
    required this.quizName,
    this.onRetry,
    this.onNext,
    this.onNextLabel = 'Lanjutkan',
    this.isExam = false, // ← tambah
  });

  @override
  Widget build(BuildContext context) {
    // Teks berbeda untuk quiz vs exam
    final successTitle = isExam
        ? 'Selamat! Kamu Lulus Final Exam 🎓'
        : 'Quiz Selesai! 🎉';
    final failTitle = isExam ? 'Belum Lulus Final Exam' : 'Belum Lulus Quiz';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPassed
                      ? const Color(0xFFEAF6F5)
                      : const Color(0xFFFFF0F0),
                ),
                child: Icon(
                  isPassed
                      ? (isExam
                            ? Icons.school_rounded
                            : Icons.check_circle_rounded)
                      : Icons.replay_rounded,
                  size: 56,
                  color: isPassed ? const Color(0xFF126E64) : Colors.redAccent,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isPassed ? successTitle : failTitle,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isPassed ? const Color(0xFF126E64) : Colors.redAccent,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                quizName,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Text(
                      '$score',
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: isPassed
                            ? const Color(0xFF126E64)
                            : Colors.redAccent,
                      ),
                    ),
                    Text(
                      'dari 100',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isPassed
                            ? const Color(0xFF126E64).withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Nilai minimal: $passingScore',
                        style: TextStyle(
                          fontSize: 12,
                          color: isPassed
                              ? const Color(0xFF126E64)
                              : Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              if (onRetry != null)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.replay),
                    label: const Text('Coba Lagi'),
                  ),
                ),
              const SizedBox(height: 10),
              if (onNext != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF126E64),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: Icon(
                      isExam
                          ? Icons.workspace_premium_rounded
                          : onNextLabel == 'Lihat Final Exam'
                          ? Icons.assignment_rounded
                          : Icons.arrow_forward,
                      color: Colors.white,
                    ),
                    label: Text(onNextLabel),
                  ),
                ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text('Kembali ke Beranda'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
