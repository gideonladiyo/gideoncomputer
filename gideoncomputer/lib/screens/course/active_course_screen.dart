import 'package:gideoncomputer/api/course_api.dart';
import 'package:gideoncomputer/model/profile/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import '../../components/course_card.dart';
import '../screen.dart';

class ActiveCourseScreen extends StatefulWidget {
  const ActiveCourseScreen({super.key});

  @override
  State<ActiveCourseScreen> createState() => _ActiveCourseScreenState();
}

class _ActiveCourseScreenState extends State<ActiveCourseScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<ProfileViewModel>(context, listen: false);
      // Hanya fetch kalau belum ada data
      if (vm.enrolledCourse.isEmpty) {
        vm.getEnrolledCourse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vm.enrolledCourse.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada kursus yang diikuti.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: vm.enrolledCourse.length,
          itemBuilder: (context, index) {
            final enrolled = vm.enrolledCourse[index];
            return GestureDetector(
              onTap: () async {
                EasyLoading.show(status: 'Loading...');
                final fresh = await CourseAPI().getEnrollmentByCourse(
                  enrolled.course!.id!,
                );
                EasyLoading.dismiss();
                if (context.mounted) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LearningCourseScreen(courseId: fresh),
                    ),
                  );
                  // Refresh setelah kembali
                  if (context.mounted) {
                    Provider.of<ProfileViewModel>(
                      context,
                      listen: false,
                    ).getEnrolledCourse();
                  }
                }
              },
              child: CourseCard(
                courseImage: enrolled.course?.courseImage ?? '',
                courseName: enrolled.course?.courseName ?? '',
              ),
            );
          },
        );
      },
    );
  }
}
