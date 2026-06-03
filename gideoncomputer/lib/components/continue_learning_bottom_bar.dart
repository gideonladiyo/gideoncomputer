import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gideoncomputer/api/course_api.dart';
import 'package:gideoncomputer/model/course/enrolled_course_model.dart';
import 'package:provider/provider.dart';

import '../model/profile/profile_viewmodel.dart';
import '../model/course/course_viewmodel.dart';
import '../screens/course/learning_course_screen.dart';

class ContinueLearningBottomBar extends StatelessWidget {
  final EnrolledCourseModel enrolledCourse;

  const ContinueLearningBottomBar({super.key, required this.enrolledCourse});

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      height: 70,
      padding: const EdgeInsets.all(12),
      child: ElevatedButton(
        onPressed: () async {
          EasyLoading.show(status: 'Loading...');

          // Fetch ulang data fresh dari Supabase
          final fresh = await CourseAPI().getEnrollmentByCourse(
            enrolledCourse.course!.id!,
          );

          EasyLoading.dismiss();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LearningCourseScreen(courseId: fresh),
            ),
          );
        },
        child: const Text('CONTINUE LEARNING'),
      ),
    );
  }
}
