import 'package:gideoncomputer/api/course_api.dart';
import 'package:gideoncomputer/model/course/enrolled_course_model.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gideoncomputer/model/course/learning_progress_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screen.dart';

class LearningCourseScreen extends StatefulWidget {
  final EnrolledCourseModel? courseId;
  final String? initURL;
  const LearningCourseScreen({super.key, this.courseId, this.initURL});

  @override
  State<LearningCourseScreen> createState() => _LearningCourseScreenState();
}

class _LearningCourseScreenState extends State<LearningCourseScreen> {
  int sectionIndex = 0;
  int materialIndex = 0;
  int reportsIndex = 0;

  late List<LearningProgressModel> _localReports;
  bool _isMarkingComplete = false;
  bool _allMaterialsDone = false;

  @override
  void initState() {
    super.initState();
    _localReports = List.from(widget.courseId?.learningProgress ?? []);
    _jumpToFirstIncomplete();
  }

  /// Cari materi pertama yang belum completed.
  /// Kalau semua sudah selesai, tetap di materi terakhir.
  void _jumpToFirstIncomplete() {
    final sections = widget.courseId?.course?.sections ?? [];
    if (sections.isEmpty) return;

    for (int si = 0; si < sections.length; si++) {
      final materials = sections[si].materials ?? [];
      for (int mi = 0; mi < materials.length; mi++) {
        final materialId = materials[mi].id;
        final isDone = _localReports.any(
          (r) => r.resolvedMaterialId == materialId && r.isCompleted == true,
        );
        if (!isDone) {
          sectionIndex = si;
          materialIndex = mi;
          return;
        }
      }
    }

    // Semua selesai — buka materi terakhir
    sectionIndex = sections.length - 1;
    final lastMaterials = sections[sectionIndex].materials ?? [];
    materialIndex = lastMaterials.isEmpty ? 0 : lastMaterials.length - 1;
  }

  // ─── Helpers ────────────────────────────────────────────────

  String _extractVideoId(String url) {
    if (url.isEmpty) return '';
    if (!url.contains('/') && !url.contains('?')) return url.trim();
    try {
      final uri = Uri.parse(url);
      if (uri.host.contains('youtube.com'))
        return uri.queryParameters['v'] ?? '';
      if (uri.host.contains('youtu.be')) {
        return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
      }
    } catch (e) {
      print('Error parsing URL: $e');
    }
    return '';
  }

  String _getCurrentVideoId() {
    final raw =
        widget
            .courseId!
            .course!
            .sections![sectionIndex]
            .materials![materialIndex]
            .url ??
        '';
    return _extractVideoId(raw);
  }

  String _getCurrentUrl() {
    return widget
            .courseId!
            .course!
            .sections![sectionIndex]
            .materials![materialIndex]
            .url ??
        '';
  }

  String get _currentMaterialId => widget
      .courseId!
      .course!
      .sections![sectionIndex]
      .materials![materialIndex]
      .id;

  String get _enrollmentId => widget.courseId!.id!;

  bool get _isCurrentCompleted {
    return _localReports.any(
      (r) =>
          r.resolvedMaterialId == _currentMaterialId && r.isCompleted == true,
    );
  }

  int get _totalMaterials => widget.courseId!.course!.sections!.fold(
    0,
    (sum, s) => sum + (s.materials?.length ?? 0),
  );

  int get _completedCount =>
      _localReports.where((r) => r.isCompleted == true).length;

  double get _progressValue =>
      _totalMaterials == 0 ? 0 : _completedCount / _totalMaterials;

  // ─── Actions ────────────────────────────────────────────────

  Future<void> _openYoutube() async {
    final url = _getCurrentUrl();
    if (url.isEmpty) {
      EasyLoading.showError('URL video tidak tersedia');
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      EasyLoading.showError('Tidak dapat membuka YouTube');
    }
  }

  Future<void> _markAsComplete() async {
    if (_isCurrentCompleted || _isMarkingComplete) return;
    setState(() => _isMarkingComplete = true);
    try {
      EasyLoading.show(status: 'Menyimpan...');
      await CourseAPI().updateCourseProgress(_enrollmentId, _currentMaterialId);
      EasyLoading.showSuccess('Materi selesai!');
      setState(() {
        final idx = _localReports.indexWhere(
          (r) => r.resolvedMaterialId == _currentMaterialId,
        );
        if (idx != -1) {
          _localReports[idx] = LearningProgressModel(
            id: _localReports[idx].id,
            isCompleted: true,
            material: _localReports[idx].material,
          );
        } else {
          _localReports.add(
            LearningProgressModel(
              isCompleted: true,
              material: widget
                  .courseId!
                  .course!
                  .sections![sectionIndex]
                  .materials![materialIndex],
            ),
          );
        }
      });
    } catch (e) {
      EasyLoading.showError('Gagal menyimpan progress');
      print('Error marking complete: $e');
    } finally {
      setState(() => _isMarkingComplete = false);
    }
  }

  void _checkAndFinish() {
    final sections = widget.courseId!.course!.sections!;

    // Kumpulkan semua material id yang NON-quiz
    final nonQuizMaterialIds = sections
        .expand((s) => s.materials ?? [])
        .where((m) => m.materialType != 'quiz')
        .map((m) => m.id)
        .toSet();

    final nonQuizTotal = nonQuizMaterialIds.length;

    // Hitung yang sudah selesai HANYA dari non-quiz material
    final nonQuizCompleted = _localReports
        .where(
          (r) =>
              r.isCompleted == true &&
              nonQuizMaterialIds.contains(r.resolvedMaterialId),
        )
        .length;

    print(
      '🔍 [_checkAndFinish] nonQuizTotal=$nonQuizTotal, nonQuizCompleted=$nonQuizCompleted',
    );

    if (nonQuizCompleted < nonQuizTotal) {
      EasyLoading.showInfo('Selesaikan semua materi terlebih dahulu!');
    } else {
      setState(() => _allMaterialsDone = true);
    }
  }

  Future<void> _refreshReports() async {
    try {
      final courseId = widget.courseId?.course?.id;
      if (courseId == null) return;
      final fresh = await CourseAPI().getEnrollmentByCourse(courseId);
      if (!mounted) return;
      setState(() {
        _localReports = List.from(fresh.learningProgress ?? []);

        final nonQuizMaterialIds = widget.courseId!.course!.sections!
            .expand((s) => s.materials ?? [])
            .where((m) => m.materialType != 'quiz')
            .map((m) => m.id)
            .toSet();

        final nonQuizTotal = nonQuizMaterialIds.length;
        final nonQuizCompleted = _localReports
            .where(
              (r) =>
                  r.isCompleted == true &&
                  nonQuizMaterialIds.contains(r.resolvedMaterialId),
            )
            .length;

        if (nonQuizCompleted >= nonQuizTotal && nonQuizTotal > 0) {
          _allMaterialsDone = true;
        }
      });
    } catch (e) {
      print('🔴 [LearningCourse] _refreshReports error: $e');
    }
  }

  void nextVideo() {
    final sections = widget.courseId!.course!.sections!;
    final materialLength = sections[sectionIndex].materials!.length;
    final sectionLength = sections.length;

    if (materialIndex < materialLength - 1) {
      setState(() {
        materialIndex++;
        reportsIndex++;
      });
    } else if (sectionIndex < sectionLength - 1) {
      setState(() {
        sectionIndex++;
        materialIndex = 0;
        reportsIndex++;
      });
    } else {
      _checkAndFinish();
    }
  }

  void prevVideo() {
    final sections = widget.courseId!.course!.sections!;
    if (materialIndex > 0) {
      setState(() {
        materialIndex--;
        reportsIndex--;
      });
    } else if (sectionIndex > 0) {
      setState(() {
        sectionIndex--;
        final prevMaterials = sections[sectionIndex].materials ?? [];
        materialIndex = prevMaterials.isEmpty ? 0 : prevMaterials.length - 1;
        reportsIndex = (reportsIndex - 1).clamp(0, double.maxFinite.toInt());
      });
    }
  }

  // ─── Build ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final enrolled = widget.courseId!;
    final sections = enrolled.course?.sections ?? [];
    if (sections.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: CircleAvatar(
              backgroundColor: const Color.fromARGB(62, 158, 158, 158),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.chevron_left_outlined,
                  color: Color(0xFF126E64),
                ),
              ),
            ),
          ),
          centerTitle: true,
          title: Text(
            enrolled.course?.courseName ?? 'Course',
            style: const TextStyle(color: Colors.black, fontSize: 14),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Materi Belum Tersedia',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kursus ini belum memiliki materi atau bab yang ditambahkan oleh admin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final materials = sections[sectionIndex].materials ?? [];
    if (materials.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tidak ada materi')),
        body: const Center(child: Text('Section ini belum memiliki materi.')),
      );
    }
    final currentMaterial = materials[materialIndex];
    final isCompleted = _isCurrentCompleted;

    return Scaffold(
      endDrawer: _buildDrawer(enrolled),
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7),
          child: CircleAvatar(
            backgroundColor: const Color.fromARGB(62, 158, 158, 158),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.chevron_left_outlined,
                color: Color(0xFF126E64),
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          widget.courseId!.course!.courseName!,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.black, fontSize: 14),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CircleAvatar(
              backgroundColor: const Color.fromARGB(62, 158, 158, 158),
              child: Builder(
                builder: (context) {
                  return IconButton(
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                    icon: const Icon(Icons.menu, color: Color(0xFF126E64)),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressBar(),
          Expanded(
            child: _allMaterialsDone
                ? _buildFinalExamBanner(context)
                : currentMaterial.materialType == 'quiz'
                ? _buildQuizBanner(context, sections[sectionIndex])
                : _buildVideoContent(context, currentMaterial, isCompleted),
          ),
        ],
      ),
    );
  }

  // ─── Final Exam Banner ───────────────────────────────────────

  Widget _buildFinalExamBanner(BuildContext context) {
    final enrolled = widget.courseId!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEAF6F5),
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 56,
                color: Color(0xFF126E64),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Semua Materi Selesai! 🎉',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Kamu telah menyelesaikan semua materi. Sekarang ikuti Final Exam untuk mendapatkan sertifikat.',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExamScreen(
                        courseId: enrolled.course!.id!,
                        courseName: enrolled.course!.courseName ?? 'Course',
                        enrolledCourse: enrolled,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF126E64),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.assignment_rounded),
                label: const Text(
                  'Mulai Final Exam',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Quiz Banner ─────────────────────────────────────────────

  Widget _buildQuizBanner(BuildContext context, section) {
    final sections = widget.courseId!.course!.sections!;
    final isLastSection = sectionIndex == sections.length - 1;
    final isLastMaterialInSection =
        materialIndex == (sections[sectionIndex].materials?.length ?? 1) - 1;
    final isLast = isLastSection && isLastMaterialInSection;

    print(
      '🔍 [QuizBanner] sectionIndex=$sectionIndex/${sections.length - 1}, '
      'materialIndex=$materialIndex/${(sections[sectionIndex].materials?.length ?? 1) - 1}, '
      'isLastSection=$isLastSection, isLastMaterialInSection=$isLastMaterialInSection, isLast=$isLast',
    );
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEAF6F5),
              ),
              child: const Icon(
                Icons.assignment_rounded,
                size: 56,
                color: Color(0xFF126E64),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              section.sectionName ?? 'Quiz',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Uji pemahamanmu sebelum melanjutkan ke section berikutnya.',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizScreen(
                        sectionId: section.id!,
                        sectionName: section.sectionName ?? 'Quiz',
                        enrollmentId: _enrollmentId,
                        quizMaterialId: _currentMaterialId,
                        isLastMaterial: isLast,
                        onCompleted: nextVideo,
                      ),
                    ),
                  ).then((_) => _refreshReports());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF126E64),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                label: const Text(
                  'Mulai Quiz',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: nextVideo,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF126E64),
                side: const BorderSide(color: Color(0xFF126E64)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Lewati, lanjut ke section berikutnya'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Video Content ───────────────────────────────────────────

  Widget _buildVideoContent(
    BuildContext context,
    currentMaterial,
    bool isCompleted,
  ) {
    final videoId = _getCurrentVideoId();
    final thumbnailUrl = videoId.isNotEmpty
        ? 'https://img.youtube.com/vi/$videoId/hqdefault.jpg'
        : null;

    return Column(
      children: [
        GestureDetector(
          onTap: _openYoutube,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (thumbnailUrl != null)
                  Image.network(
                    thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _thumbnailPlaceholder(),
                  )
                else
                  _thumbnailPlaceholder(),
                Container(color: Colors.black.withOpacity(0.25)),
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.open_in_new, color: Colors.white, size: 13),
                        SizedBox(width: 4),
                        Text(
                          'Tonton di YouTube',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        currentMaterial.materialName ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (isCompleted)
                      Container(
                        margin: const EdgeInsets.only(left: 8, top: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF126E64),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 13,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Selesai',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                if (currentMaterial.description != null &&
                    currentMaterial.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  MarkdownBody(
                    data: currentMaterial.description!,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.4,
                        fontFamily: 'Poppins',
                      ),
                      strong: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                        fontFamily: 'Poppins',
                      ),
                      em: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Poppins',
                      ),
                      listBullet: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        fontFamily: 'Poppins',
                      ),
                      h3: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF126E64),
                        fontFamily: 'Poppins',
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isCompleted ? null : _markAsComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCompleted
                          ? Colors.grey[300]
                          : const Color(0xFF126E64),
                      foregroundColor: isCompleted
                          ? Colors.grey[600]
                          : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: _isMarkingComplete
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            isCompleted
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                          ),
                    label: Text(
                      isCompleted ? 'Sudah Selesai' : 'Tandai Selesai',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: prevVideo,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF126E64),
                          side: const BorderSide(color: Color(0xFF126E64)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Previous',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: nextVideo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF126E64),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Next Video',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Progress bar ────────────────────────────────────────────

  Widget _buildProgressBar() {
    final percent = (_progressValue * 100).toStringAsFixed(0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_completedCount / $_totalMaterials materi selesai',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                '$percent%',
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
              value: _progressValue,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                _progressValue >= 1.0 ? Colors.green : const Color(0xFF126E64),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Placeholder thumbnail ───────────────────────────────────

  Widget _thumbnailPlaceholder() {
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Icon(Icons.videocam_off, color: Colors.white54, size: 48),
      ),
    );
  }

  // ─── Drawer ──────────────────────────────────────────────────

  Widget _buildDrawer(EnrolledCourseModel enrolled) {
    return Drawer(
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Progress Kursus',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$_completedCount / $_totalMaterials',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        '${(_progressValue * 100).toStringAsFixed(0)}%',
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
                      value: _progressValue,
                      minHeight: 6,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _progressValue >= 1.0
                            ? Colors.green
                            : const Color(0xFF126E64),
                      ),
                    ),
                  ),
                  const Divider(height: 20),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: enrolled.course?.sections?.length ?? 0,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final section = enrolled.course!.sections![index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.sectionName!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: section.materials?.length ?? 0,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, subIndex) {
                          final material = section.materials![subIndex];
                          final isActive =
                              sectionIndex == index &&
                              materialIndex == subIndex;
                          final isDone = _localReports.any(
                            (r) =>
                                r.resolvedMaterialId == material.id &&
                                r.isCompleted == true,
                          );
                          return ListTile(
                            onTap: () {
                              Navigator.pop(context);
                              if (material.materialType == 'quiz') {
                                final sections =
                                    widget.courseId!.course!.sections!;
                                final isLastSection =
                                    index == sections.length - 1;
                                final isLastMaterialInSection =
                                    subIndex ==
                                    (sections[index].materials?.length ?? 1) -
                                        1;
                                final isLast =
                                    isLastSection && isLastMaterialInSection;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => QuizScreen(
                                      sectionId: section.id!,
                                      sectionName:
                                          section.sectionName ?? 'Quiz',
                                      enrollmentId: _enrollmentId,
                                      quizMaterialId: material.id,
                                      isLastMaterial: isLast, // ← tambah
                                      onCompleted: nextVideo,
                                    ),
                                  ),
                                );
                                return;
                              }
                              final reportList = enrolled.learningProgress ?? [];
                              int newReportsIndex = reportList.indexWhere(
                                (i) => i.material!.id == material.id,
                              );
                              if (newReportsIndex == -1) newReportsIndex = 0;
                              setState(() {
                                sectionIndex = index;
                                materialIndex = subIndex;
                                reportsIndex = newReportsIndex;
                              });
                            },
                            tileColor: isActive
                                ? const Color(0xFFD0EDE9)
                                : Colors.grey[200],
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                            leading: material.materialType == 'slide'
                                ? const Icon(Icons.slideshow_rounded)
                                : material.materialType == 'quiz'
                                ? const Icon(Icons.history_edu_rounded)
                                : Icon(
                                    Icons.play_circle_filled_rounded,
                                    color: isActive
                                        ? const Color(0xFF126E64)
                                        : null,
                                  ),
                            title: Text(material.materialName ?? ''),
                            trailing: isDone
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF126E64),
                                    size: 18,
                                  )
                                : null,
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
