import 'package:gideoncomputer/components/logo.dart';
import 'package:gideoncomputer/model/profile/profile_viewmodel.dart';
import 'package:gideoncomputer/screens/homescreen/main_page.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../model/auth/auth_viewmodel.dart';
import '../../model/wishlist/wishlist_viewmodel.dart';
import '../../model/assessment/assessment_viewmodel.dart';
import '../../model/certificate/certificate_viewmodel.dart';
import '../../model/course/course_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var formKey = GlobalKey<FormState>();
  bool _passwordVisible = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var data = Provider.of<AuthViewModel>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Logo(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const buildLoginTextHeader(),
              Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Email'),
                    buildEmailField(emailController: emailController),
                    const SizedBox(height: 14),
                    const Text('Password'),
                    TextFormField(
                      controller: passwordController,
                      obscureText: !_passwordVisible,
                      validator: (val) {
                        if (val != null && val.length < 4) {
                          return 'Masukkan Minimal 4 Karakter';
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                        hintText: 'Enter your password',
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                          icon: Icon(_passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/forgetPassword'),
                    child: const Text(
                      'Forget password?',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () async {
                          final isValidForm = formKey.currentState!.validate();
        
                          if (isValidForm) {
                            try {
                              await data.login(
                                emailController.text,
                                passwordController.text,
                              );

                              if (!mounted) return;

                              // Reset all ViewModels to clear cache from previous user sessions
                              if (context.mounted) {
                                Provider.of<ProfileViewModel>(context, listen: false).reset();
                                Provider.of<WishlistViewModel>(context, listen: false).reset();
                                Provider.of<AssessmentViewModel>(context, listen: false).reset();
                                Provider.of<CertificateViewModel>(context, listen: false).reset();
                                Provider.of<CourseViewModel>(context, listen: false).reset();
                              }

                              Future.microtask(() {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => MainPage()),
                                  (route) => false,
                                );
                              });
                            } catch (e) {
                              // error sudah ditangani di AuthAPI (EasyLoading)
                            }
                          }
                        },
                        child: const Text('LOGIN'),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an account?'),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: const Text(
                      'Register',
                      style: TextStyle(color: Color(0xFF126E64)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class buildLoginTextHeader extends StatelessWidget {
  const buildLoginTextHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      height: 230,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/login_hero.png',
            width: 200,
            height: 160,
            cacheWidth: 300,
            filterQuality: FilterQuality.low,
          ),
          const Text(
            'Welcome Back',
            style: TextStyle(fontSize: 28),
          ),
          const Text(
            'Please login with your account to continue',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class buildEmailField extends StatelessWidget {
  const buildEmailField({
    super.key,
    required this.emailController,
  });

  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: emailController,
      validator: (email) {
        if (email != null && !EmailValidator.validate(email)) {
          return 'Masukkan email dengan benar';
        } else {
          return null;
        }
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        hintText: 'Enter your email',
      ),
    );
  }
}

class DummyScreen extends StatelessWidget {
  const DummyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthViewModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Dummy Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Login berhasil 🚀'),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
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
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              child: const Text('LOGOUT'),
            ),
          ],
        ),
      ),
    );
  }
}