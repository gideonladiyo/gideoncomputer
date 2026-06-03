import 'package:gideoncomputer/model/course/course_viewmodel.dart';
import 'package:gideoncomputer/model/profile/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:lottie/lottie.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import '../screen.dart';
import '../../api/certificate_api.dart';
import '../../components/data.dart';
import '../../model/course/enrolled_course_model.dart';

class SuccessCourseScreen extends StatefulWidget {
  const SuccessCourseScreen({super.key});

  @override
  State<SuccessCourseScreen> createState() => _SuccessCourseScreenState();
}

class _SuccessCourseScreenState extends State<SuccessCourseScreen> {
  int ratingValue = 0;
  TextEditingController reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final data =
        ModalRoute.of(context)!.settings.arguments as EnrolledCourseModel;
    final user = Provider.of<ProfileViewModel>(context);

    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 150,
                  child: Lottie.asset('assets/success.json'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'What a Day!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Finally you have completed the ${data.course?.courseName} course very well.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),

                // ── Tombol Final Exam ──────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExamScreen(
                                courseId: data.course!.id!,
                                courseName: data.course!.courseName ?? 'Course',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF126E64),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(
                          Icons.assignment_rounded,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'MULAI FINAL EXAM',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // ── Download Certificate ───────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final certificateFile = await CertificateAPI.generate(
                            PdfPageFormat.a4,
                            CustomData(
                              name: '${user.userData.fullname?.toUpperCase()}',
                              courseName: data.course?.courseName,
                            ),
                          );
                          CertificateAPI.openFile(certificateFile);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF126E64),
                          side: const BorderSide(color: Color(0xFF126E64)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'DOWNLOAD CERTIFICATE',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // ── Rating Course ──────────────────────────────────
                // Row(
                //   children: [
                //     Expanded(
                //       child: OutlinedButton(
                //         onPressed: () {
                //           showDialog(
                //             context: context,
                //             builder: (dialogContext) {
                //               return SimpleDialog(
                //                 titlePadding: const EdgeInsets.fromLTRB(
                //                   16,
                //                   0,
                //                   0,
                //                   0,
                //                 ),
                //                 contentPadding: const EdgeInsets.symmetric(
                //                   horizontal: 8,
                //                 ),
                //                 title: Row(
                //                   mainAxisAlignment:
                //                       MainAxisAlignment.spaceBetween,
                //                   children: [
                //                     const Text(
                //                       'Rating a Course',
                //                       style: TextStyle(fontSize: 16),
                //                     ),
                //                     IconButton(
                //                       onPressed: () =>
                //                           Navigator.pop(dialogContext),
                //                       icon: const Icon(Icons.close_outlined),
                //                     ),
                //                   ],
                //                 ),
                //                 children: [
                //                   Padding(
                //                     padding: const EdgeInsets.all(8.0),
                //                     child: Text(data.course!.courseName!),
                //                   ),
                //                   RatingBar.builder(
                //                     initialRating: 1,
                //                     minRating: 1,
                //                     direction: Axis.horizontal,
                //                     itemCount: 5,
                //                     itemPadding: const EdgeInsets.symmetric(
                //                       horizontal: 4.0,
                //                       vertical: 2,
                //                     ),
                //                     itemBuilder: (context, _) => const Icon(
                //                       Icons.star,
                //                       color: Colors.amber,
                //                     ),
                //                     onRatingUpdate: (rating) {
                //                       setState(
                //                         () => ratingValue = rating.toInt(),
                //                       );
                //                     },
                //                   ),
                //                   const SizedBox(height: 8),
                //                   TextFormField(
                //                     controller: reviewController,
                //                     decoration: const InputDecoration(
                //                       hintText: 'Write review...',
                //                       border: OutlineInputBorder(),
                //                     ),
                //                     minLines: 5,
                //                     keyboardType: TextInputType.multiline,
                //                     maxLines: null,
                //                   ),
                //                   ElevatedButton(
                //                     onPressed: () {
                //                       Navigator.pushReplacementNamed(
                //                         context,
                //                         '/mainpage',
                //                       );
                //                     },
                //                     child: const Text('SUBMIT'),
                //                   ),
                //                 ],
                //               );
                //             },
                //           );
                //         },
                //         child: const Text('RATING COURSE'),
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
