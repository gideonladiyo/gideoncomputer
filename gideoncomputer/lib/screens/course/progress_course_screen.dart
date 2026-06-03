import 'package:gideoncomputer/components/course_progress_card.dart';
import 'package:gideoncomputer/model/profile/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class ProgressCourseScreen extends StatefulWidget {
  const ProgressCourseScreen({super.key});

  @override
  State<ProgressCourseScreen> createState() => _ProgressCourseScreenState();
}

class _ProgressCourseScreenState extends State<ProgressCourseScreen> {
  @override
  Widget build(BuildContext context) {
    final data = Provider.of<ProfileViewModel>(context);
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: data.enrolledCourse.length,
        itemBuilder: (context, index) {
          final enrolled = data.enrolledCourse[index];

          final totalMaterials =
              enrolled.course?.sections
                  ?.expand((e) => e.materials ?? [])
                  .length ??
              0;

          final completedMaterials =
              enrolled.learningProgress?.where((e) => e.isCompleted == true).length ?? 0;

          final progress = totalMaterials == 0
              ? 0.0
              : completedMaterials / totalMaterials;

          final progressPercent = (progress * 100).toInt();

          return CourseProgressCard(
            courseImage: enrolled.course?.courseImage ?? '',
            courseName: enrolled.course?.courseName ?? '',
            categoryName: enrolled.course?.category?.categoryName ?? '',
            progress: progress,
            teksProgressPersen: progressPercent,
          );
        },
      ),
    );
  }
}
