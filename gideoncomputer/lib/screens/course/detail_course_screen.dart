import 'package:gideoncomputer/components/disabled_enroll_bottom_bar.dart';
import 'package:gideoncomputer/model/course/course_model.dart';
import 'package:gideoncomputer/model/profile/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../components/continue_learning_bottom_bar.dart';
import '../../components/enroll_bottom_bar.dart';
import '../../components/review_card.dart';
import '../../components/tools_card.dart';
import '../../model/course/course_viewmodel.dart';
import '../../model/wishlist/wishlist_viewmodel.dart';

class DetailCourseScreen extends StatefulWidget {
  final CourseModel? courseId;
  const DetailCourseScreen({super.key, this.courseId});

  @override
  State<DetailCourseScreen> createState() => _DetailCourseScreenState();
}

class _DetailCourseScreenState extends State<DetailCourseScreen> {
  CourseModel? _fullCourse;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      Provider.of<ProfileViewModel>(context, listen: false).getEnrolledCourse();
      Provider.of<WishlistViewModel>(context, listen: false).fetchWishlists();
      // Fetch data lengkap termasuk sections, materials, tools
      if (widget.courseId?.id != null) {
        try {
          final full = await Provider.of<CourseViewModel>(
            context,
            listen: false,
          ).getCourseById(widget.courseId!.id!);
          if (mounted) setState(() => _fullCourse = full);
        } catch (e) {
          print('🔴 [DetailCourseScreen] fetchFull ERROR: $e');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // final detail = Provider.of<CourseViewModel>(context);
    final wishlist = Provider.of<WishlistViewModel>(context);
    final enrolledCourseData = Provider.of<ProfileViewModel>(context);

    final isEnrolled = enrolledCourseData.enrolledCourse.any(
      (e) => e.course?.id == widget.courseId!.id,
    );
    final enrolledCourse = isEnrolled
        ? enrolledCourseData.enrolledCourse.firstWhere(
            (e) => e.course?.id == widget.courseId!.id,
          )
        : null;
    if (enrolledCourseData.isLoading) {
      return const SizedBox();
    }
    print("ENROLLED LIST: ${enrolledCourseData.enrolledCourse}");
    print("COURSE ID: ${widget.courseId!.id}");
    for (var e in enrolledCourseData.enrolledCourse) {
      print("ENROLLED RAW: $e");
      print("COURSE OBJ: ${e.course}");
      print("COURSE ID: ${e.course?.id}");
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(250),
          child: AppBar(
            leading: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: CircleAvatar(
                backgroundColor: const Color.fromARGB(62, 158, 158, 158),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.chevron_left_outlined,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            titleTextStyle: const TextStyle(color: Colors.white),
            centerTitle: true,
            flexibleSpace: Container(
              height: 220,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.courseId!.courseImage!),
                  onError: (exception, stackTrace) {
                    Image.asset('assets/empty_image.png', fit: BoxFit.cover);
                  },
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    const Color(0xFFD32F2F).withOpacity(1),
                    BlendMode.darken,
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.courseId!.courseName ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return SimpleDialog(
                              contentPadding: EdgeInsets.zero,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: 200,
                                  child: YoutubePlayer(
                                    bottomActions: [
                                      CurrentPosition(),
                                      ProgressBar(isExpanded: true),
                                      RemainingDuration(),
                                    ],
                                    controller: YoutubePlayerController(
                                      initialVideoId:
                                          YoutubePlayer.convertUrlToId(
                                            widget
                                                    .courseId!
                                                    .sections?[0]
                                                    .materials?[0]
                                                    .url ??
                                                '',
                                          ) ??
                                          '',
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.play_circle_outline_outlined,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Preview Course',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            title: const Text(
              'Details Course',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: CircleAvatar(
                  backgroundColor: const Color.fromARGB(62, 158, 158, 158),
                  child: Builder(
                    builder: (context) {
                      final wl = Provider.of<WishlistViewModel>(context);
                      final isBookmarked = wl.isWishlisted(
                        widget.courseId?.id ?? '',
                      );
                      return IconButton(
                        onPressed: () async {
                          if (widget.courseId == null) return;
                          await wl.toggleWishlist(widget.courseId!);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isBookmarked
                                    ? 'Dihapus dari Wishlist'
                                    : 'Ditambahkan ke Wishlist!',
                              ),
                            ),
                          );
                        },
                        icon: Icon(
                          isBookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_outline,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            bottom: const TabBar(
              indicatorSize: TabBarIndicatorSize.label,
              indicatorColor: Color(0xFFD32F2F),
              labelColor: Colors.black,
              tabs: [
                Tab(text: 'About'),
                Tab(text: 'Lesson'),
                Tab(text: 'Tools'),
                Tab(text: 'Reviews'),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  AboutTabSection(data: widget.courseId),
                  LessonTabSection(course: _fullCourse ?? widget.courseId),
                  ToolsTabSection(course: _fullCourse ?? widget.courseId),
                  const ReviewsTabSection(),
                ],
              ),
            ),
            isEnrolled
                ? ContinueLearningBottomBar(enrolledCourse: enrolledCourse!)
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Info cara enroll
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        color: const Color(0xFFFFEBEE),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Color(0xFFD32F2F),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Hubungi admin via WhatsApp untuk mendapatkan kode akses course.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      EnrollBottomBar(
                        courseId: widget.courseId!.id!,
                        courseName: widget.courseId!.courseName ?? 'Course',
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class AboutTabSection extends StatelessWidget {
  final CourseModel? data;
  const AboutTabSection({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    final detail = Provider.of<CourseViewModel>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    data?.description ?? '',
                    // detail.courseData.description ?? '',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class LessonTabSection extends StatelessWidget {
  final CourseModel? course;
  const LessonTabSection({super.key, this.course});

  IconData _iconForType(String? type) {
    switch (type) {
      case 'slide':
      case 'pdf':
        return Icons.slideshow_rounded;
      case 'quiz':
        return Icons.history_edu_rounded;
      default:
        return Icons.play_circle_filled_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sections = course?.sections ?? [];

    if (sections.isEmpty) {
      return const Center(
        child: Text('Belum ada materi.', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: sections.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final section = sections[index];
        final materials = section.materials ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                section.sectionName ?? 'Section ${index + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...materials.map(
              (material) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  tileColor: Colors.grey[100],
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  leading: Icon(
                    _iconForType(material.materialType),
                    color: const Color(0xFFD32F2F),
                  ),
                  title: Text(
                    material.materialName ?? '',
                    style: const TextStyle(fontSize: 13),
                  ),
                  trailing: Text(
                    material.materialType ?? '',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ToolsTabSection extends StatelessWidget {
  final CourseModel? course;
  const ToolsTabSection({super.key, this.course});

  @override
  Widget build(BuildContext context) {
    final tools = course?.tools ?? [];

    if (tools.isEmpty) {
      return const Center(
        child: Text('Belum ada tools.', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        return ToolsCard(
          toolsName: tools[index].toolsName,
          imgUrl: tools[index].toolsIcon,
          toolUrl: tools[index].url,
        );
      },
    );
  }
}

class ReviewsTabSection extends StatefulWidget {
  const ReviewsTabSection({super.key});

  @override
  State<ReviewsTabSection> createState() => _ReviewsTabSectionState();
}

class _ReviewsTabSectionState extends State<ReviewsTabSection> {
  @override
  Widget build(BuildContext context) {
    final review = Provider.of<CourseViewModel>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: review.allReview?.length ?? 0,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemBuilder: (context, index) {
              return ReviewCard(
                img: review.allReview?[index].user?.avatar ?? '',
                title: review.allReview?[index].user?.fullname ?? '',
                rating: review.allReview?[index].rating ?? 1,
                desc: review.allReview?[index].review ?? '',
              );
            },
          ),
        ),
      ],
    );
  }
}
