import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../model/auth/auth_viewmodel.dart';
import '../../model/course/enrolled_course_model.dart';
import '../../model/profile/profile_viewmodel.dart';
import '../../model/wishlist/wishlist_viewmodel.dart';
import '../../model/assessment/assessment_viewmodel.dart';
import '../../model/certificate/certificate_viewmodel.dart';
import '../../model/course/course_viewmodel.dart';
import '../course/learning_course_screen.dart';
import '../../api/course_api.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    final vm = Provider.of<ProfileViewModel>(context, listen: false);
    vm.getWhoLogin();
    vm.getEnrolledCourse();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<ProfileViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        title: const Text('Profile'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CircleAvatar(
              backgroundColor: const Color.fromARGB(62, 158, 158, 158),
              child: IconButton(
                onPressed: () => Navigator.pushNamed(context, '/editProfile'),
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const ProfileHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── My Course Progress ──────────────────────────
                  _EnrolledCourseSection(),
                  const SizedBox(height: 8),

                  // ── Menu List ───────────────────────────────────
                  ListTile(
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/myCourse',
                      arguments: user.userData,
                    ),
                    tileColor: Colors.white,
                    iconColor: const Color(0xFFD32F2F),
                    shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      side: const BorderSide(color: Color(0xFFFFEBEE), width: 1.5),
                    ),
                    title: const Text(
                      'My Course',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    trailing: const Icon(Icons.chevron_right_outlined),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    onTap: () => Navigator.pushNamed(context, '/certificate'),
                    tileColor: Colors.white,
                    iconColor: const Color(0xFFD32F2F),
                    shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      side: const BorderSide(color: Color(0xFFFFEBEE), width: 1.5),
                    ),
                    title: const Text(
                      'Certificate',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    trailing: const Icon(Icons.chevron_right_outlined),
                  ),
                  // const SizedBox(height: 16),
                  // ListTile(
                  //   onTap: () => Navigator.pushNamed(context, '/dataReport'),
                  //   tileColor: Colors.grey[200],
                  //   shape: const RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.all(Radius.circular(5)),
                  //   ),
                  //   title: const Text('Data Report'),
                  //   trailing: const Icon(Icons.chevron_right_outlined),
                  // ),
                  // const SizedBox(height: 16),
                  // ListTile(
                  //   onTap: () => Navigator.pushNamed(context, '/formRequest'),
                  //   tileColor: Colors.grey[200],
                  //   shape: const RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.all(Radius.circular(5)),
                  //   ),
                  //   title: const Text('Request'),
                  //   trailing: const Icon(Icons.chevron_right_outlined),
                  // ),
                  // const SizedBox(height: 16),
                  // ListTile(
                  //   onTap: () => Navigator.pushNamed(context, '/faq'),
                  //   tileColor: Colors.grey[200],
                  //   shape: const RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.all(Radius.circular(5)),
                  //   ),
                  //   title: const Text('FAQ'),
                  //   trailing: const Icon(Icons.chevron_right_outlined),
                  // ),
                  const SizedBox(height: 16),
                  ListTile(
                    onTap: () {
                      String? encodeQueryParameters(
                        Map<String, String> params,
                      ) {
                        return params.entries
                            .map(
                              (e) =>
                                  '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
                            )
                            .join('&');
                      }

                      final Uri emailLaunchUri = Uri(
                        scheme: 'mailto',
                        path: 'gideonladiyo12@gmail.com',
                        query: encodeQueryParameters(<String, String>{
                          'subject': 'Test',
                        }),
                      );

                      launchUrl(emailLaunchUri);
                    },
                    tileColor: Colors.white,
                    iconColor: const Color(0xFFD32F2F),
                    shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      side: const BorderSide(color: Color(0xFFFFEBEE), width: 1.5),
                    ),
                    title: const Text(
                      'Email Support',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    trailing: const Icon(Icons.chevron_right_outlined),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    onTap: () async {
                      final auth = Provider.of<AuthViewModel>(
                        context,
                        listen: false,
                      );
                      await auth.logout();
                      
                      // Reset all ViewModels to clear cache
                      if (context.mounted) {
                        Provider.of<ProfileViewModel>(context, listen: false).reset();
                        Provider.of<WishlistViewModel>(context, listen: false).reset();
                        Provider.of<AssessmentViewModel>(context, listen: false).reset();
                        Provider.of<CertificateViewModel>(context, listen: false).reset();
                        Provider.of<CourseViewModel>(context, listen: false).reset();
                      }

                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/',
                          (route) => false,
                        );
                      }
                    },
                    tileColor: Colors.white,
                    iconColor: const Color(0xFFD32F2F),
                    shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      side: const BorderSide(color: Color(0xFFFFEBEE), width: 1.5),
                    ),
                    leading: const Icon(Icons.logout_outlined),
                    title: const Text(
                      'Logout',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFD32F2F)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Enrolled Course Section ────────────────────────────────────────────────

class _EnrolledCourseSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final courses = vm.enrolledCourse;

        if (courses.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kursus Saya',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/myCourse'),
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: courses.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) =>
                    _CourseProgressCard(enrolled: courses[i]),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

// ── Course Progress Card ───────────────────────────────────────────────────

class _CourseProgressCard extends StatelessWidget {
  final EnrolledCourseModel enrolled;
  const _CourseProgressCard({required this.enrolled});

  int get _total =>
      enrolled.course?.sections?.expand((s) => s.materials ?? []).length ?? 0;

  int get _completed =>
      enrolled.learningProgress?.where((r) => r.isCompleted == true).length ?? 0;

  double get _progress => _total == 0 ? 0 : _completed / _total;

  bool get _isDone => _total > 0 && _completed == _total;

  @override
  Widget build(BuildContext context) {
    final course = enrolled.course;
    final percent = (_progress * 100).toStringAsFixed(0);

    return GestureDetector(
      onTap: () async {
        EasyLoading.show(status: 'Loading...');
        final fresh = await CourseAPI().getEnrollmentByCourse(course!.id!);
        EasyLoading.dismiss();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LearningCourseScreen(courseId: fresh),
          ),
        );
      },
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: course?.courseImage != null
                  ? Image.network(
                      course!.courseImage!,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course?.courseName ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 6,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _isDone ? Colors.green : const Color(0xFFD32F2F),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$_completed/$_total materi',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                      Text(
                        _isDone ? '✓ Selesai' : '$percent%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _isDone
                              ? Colors.green
                              : const Color(0xFFD32F2F),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 100,
      width: double.infinity,
      color: Colors.grey[200],
      child: const Icon(Icons.book_outlined, color: Colors.grey, size: 36),
    );
  }
}

// ── Profile Header ─────────────────────────────────────────────────────────

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      width: double.infinity,
      height: 200,
      child: Consumer<ProfileViewModel>(
        builder: (context, user, child) {
          if (user.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                flex: 2,
                fit: FlexFit.tight,
                child: CircleAvatar(
                  backgroundColor: Colors.grey[400],
                  radius: 50,
                  child:
                      user.userData.avatar != null &&
                          user.userData.avatar!.isNotEmpty
                      ? CircleAvatar(
                          radius: 45,
                          backgroundImage: NetworkImage(user.userData.avatar!),
                        )
                      : const CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),
              Flexible(
                fit: FlexFit.loose,
                flex: 1,
                child: Text(
                  user.userData.fullname ?? 'User',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
