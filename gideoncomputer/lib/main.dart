import 'package:gideoncomputer/model/course/course_viewmodel.dart';
import 'package:gideoncomputer/screens/screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'model/auth/auth_viewmodel.dart';
import 'model/profile/profile_viewmodel.dart';
import 'model/wishlist/wishlist_viewmodel.dart';
import 'model/course/enrolled_course_model.dart';
import 'model/assessment/assessment_viewmodel.dart';
import 'model/certificate/certificate_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => CourseViewModel()),
        ChangeNotifierProvider(create: (_) => WishlistViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => AssessmentViewModel()), // ← baru
        ChangeNotifierProvider(create: (_) => CertificateViewModel()), 
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Gideon Computer',
        theme: ThemeData(
          primaryColor: const Color(0xFF126E64),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF126E64),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF126E64),
              side: const BorderSide(color: Color(0xFF126E64)),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          checkboxTheme: CheckboxThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          fontFamily: 'Poppins',
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: Color(0xFF126E64),
          ),
        ),
        builder: EasyLoading.init(),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgetPassword': (context) => const ForgetPasswordScreen(),
          '/confirmPasswordReset': (context) =>
              const ConfirmPasswordResetScreen(),
          '/passwordReset': (context) => const PasswordResetScreen(),
          '/passwordResetSuccess': (context) =>
              const PasswordResetSuccessScreen(),
          '/mainpage': (context) => MainPage(),
          '/homeScreen': (context) => const HomeScreen(),
          '/courseScreen': (context) => const CourseScreen(),
          '/myCourse': (context) => const MyCourseScreen(),
          '/detailCourse': (context) => const DetailCourseScreen(),
          '/learningCourse': (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments
                    as EnrolledCourseModel;
            return LearningCourseScreen(courseId: args);
          },
          '/successCourse': (context) => const SuccessCourseScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/editProfile': (context) => const EditProfileScreen(),
          '/faq': (context) => const FAQScreen(),
          '/formRequest': (context) => const FormRequestScreen(),
          '/certificate': (context) => const CertificateScreen(),
          '/dataReport': (context) => const DataReportScreen(),
          '/search': (context) => const SearchScreen(),
        },
      ),
    );
  }
}
