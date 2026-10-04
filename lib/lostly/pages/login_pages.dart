import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../app_language.dart';
import 'signup_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.appLanguage,
  });

  final AppLanguage appLanguage;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // ---------------------------------------------------------------------------
  // FORM
  // ---------------------------------------------------------------------------

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------

  bool _hidePassword = true;
  bool _isLoading = false;

  bool get _isArabic => widget.appLanguage.isArabic;

  // ---------------------------------------------------------------------------
  // COLORS
  // ---------------------------------------------------------------------------

  static const Color brown = Color.fromARGB(255, 122, 94, 94);

  static const Color darkBrown = Color.fromARGB(255, 98, 75, 75);

  static const Color mutedBrown = Color.fromARGB(255, 152, 127, 113);

  static const Color emailAccent = Color.fromARGB(255, 229, 141, 74);

  static const Color passwordAccent = Color.fromARGB(255, 174, 97, 181);

  static const Color errorColor = Color(0xFFC9796E);

  // ---------------------------------------------------------------------------
  // TEXT
  // ---------------------------------------------------------------------------

  String get title {
    return _isArabic ? 'مرحبًا بعودتك!' : 'Welcome back !';
  }

  String get subtitle {
    return _isArabic
        ? 'سجّلي الدخول للمتابعة.'
        : 'Log in to continue your journey.';
  }

  String get emailLabel {
    return _isArabic ? 'البريد الإلكتروني' : 'Email';
  }

  String get emailHint {
    return _isArabic ? 'أدخلي بريدك الإلكتروني' : 'Enter your email';
  }

  String get passwordLabel {
    return _isArabic ? 'كلمة المرور' : 'Password';
  }

  String get passwordHint {
    return _isArabic ? 'أدخلي كلمة المرور' : 'Enter your password';
  }

  String get login {
    return _isArabic ? 'تسجيل الدخول' : 'Log in';
  }

  // ---------------------------------------------------------------------------
  // VALIDATION
  // ---------------------------------------------------------------------------

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return _isArabic ? 'أدخلي بريدك الإلكتروني' : 'Please enter your email';
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(email)) {
      return _isArabic
          ? 'أدخلي بريدًا إلكترونيًا صحيحًا'
          : 'Please enter a valid email';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return _isArabic ? 'أدخلي كلمة المرور' : 'Please enter a password';
    }

    if (password.length < 6) {
      return _isArabic
          ? 'يجب أن تحتوي على 6 أحرف على الأقل'
          : 'Use at least 6 characters';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // LOGIN WITH FIREBASE
  // ---------------------------------------------------------------------------

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Use the SAME AppLanguage instance used by the whole app.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(
            appLanguage: widget.appLanguage,
          ),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'user-not-found':
          message = _isArabic
              ? 'لا يوجد حساب بهذا البريد الإلكتروني.'
              : 'No account found with this email.';
          break;

        case 'wrong-password':
        case 'invalid-credential':
          message = _isArabic
              ? 'البريد الإلكتروني أو كلمة المرور غير صحيحة.'
              : 'Incorrect email or password.';
          break;

        case 'invalid-email':
          message = _isArabic
              ? 'البريد الإلكتروني غير صحيح.'
              : 'The email address is invalid.';
          break;

        case 'user-disabled':
          message = _isArabic
              ? 'تم تعطيل هذا الحساب.'
              : 'This account has been disabled.';
          break;

        case 'too-many-requests':
          message = _isArabic
              ? 'تمت محاولات كثيرة. حاولي مرة أخرى لاحقًا.'
              : 'Too many attempts. Please try again later.';
          break;

        case 'network-request-failed':
          message = _isArabic
              ? 'تحققي من اتصال الإنترنت وحاولي مرة أخرى.'
              : 'Check your internet connection and try again.';
          break;

        default:
          message = _isArabic
              ? 'حدث خطأ أثناء تسجيل الدخول. حاولي مرة أخرى.'
              : 'Something went wrong while logging in. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: errorColor,
          content: Text(
            message,
            textDirection:
                _isArabic ? TextDirection.rtl : TextDirection.ltr,
            style: const TextStyle(
              fontFamily: 'serif',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: errorColor,
          content: Text(
            _isArabic
                ? 'حدث خطأ غير متوقع. حاولي مرة أخرى.'
                : 'An unexpected error occurred. Please try again.',
            style: const TextStyle(
              fontFamily: 'serif',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // FIELD ICON
  // ---------------------------------------------------------------------------

  Widget _fieldIcon(
    IconData icon,
    Color accent,
  ) {
    return SizedBox(
      width: 44,
      child: Center(
        child: Icon(
          icon,
          size: 19,
          color: accent,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INPUT FIELD
  // ---------------------------------------------------------------------------

  Widget _input({
    required String label,
    required String hint,
    required IconData icon,
    required Color accent,
    required TextEditingController controller,
    required String? Function(String?) validator,
    Widget? suffix,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment:
              _isArabic ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            label,
            textDirection:
                _isArabic ? TextDirection.rtl : TextDirection.ltr,
            textAlign:
                _isArabic ? TextAlign.right : TextAlign.left,
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
              color: Color.fromARGB(255, 116, 44, 46),
            ),
          ),
        ),

        const SizedBox(height: 6),

        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          cursorColor: accent,
          textDirection:
              _isArabic ? TextDirection.rtl : TextDirection.ltr,
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 14,
            color: Color.fromARGB(255, 38, 37, 37),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.88),
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'serif',
              fontSize: 11,
              color: Color(0xFFA99A91),
            ),
            prefixIcon: _fieldIcon(
              icon,
              accent,
            ),
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: darkBrown.withValues(alpha: 0.08),
                width: 0.8,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: accent.withValues(alpha: 0.85),
                width: 1.6,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: darkBrown.withValues(alpha: 0.08),
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: errorColor,
                width: 1.2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: errorColor,
                width: 1.5,
              ),
            ),
            errorStyle: const TextStyle(
              fontFamily: 'serif',
              fontSize: 8.5,
              color: errorColor,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // LANGUAGE BUTTON
  // ---------------------------------------------------------------------------

  Widget _languageButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: darkBrown.withValues(alpha: 0.10),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            final newLanguage =
                widget.appLanguage.isArabic ? 'English' : 'العربية';

            await widget.appLanguage.changeLanguage(newLanguage);

            if (mounted) {
              setState(() {});
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.language_rounded,
                  size: 16,
                  color: Color(0xFFAE6365),
                ),
                const SizedBox(width: 5),
                Text(
                  _isArabic ? 'English' : 'اللغة العربية',
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 13.6,
                    fontWeight: FontWeight.w700,
                    color: Color.fromARGB(
                      255,
                      129,
                      73,
                      75,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final direction =
        _isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFFF1E4),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // -------------------------------------------------------------------
          // BACKGROUND
          // -------------------------------------------------------------------

          Image.asset(
            'assets/avatar9.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),

          // -------------------------------------------------------------------
          // SOFT OVERLAY
          // -------------------------------------------------------------------

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  const Color(0xFFFFF1E4).withValues(alpha: 0.04),
                  const Color(0xFFFFF1E4).withValues(alpha: 0.16),
                ],
              ),
            ),
          ),

          // -------------------------------------------------------------------
          // CONTENT
          // -------------------------------------------------------------------

          SafeArea(
            child: Directionality(
              textDirection: direction,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final contentWidth =
                      (constraints.maxWidth - 32).clamp(
                    280.0,
                    318.0,
                  );

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      7,
                      16,
                      20,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // -----------------------------------------------------------------
                          // LANGUAGE
                          // -----------------------------------------------------------------

                          Align(
                            alignment: _isArabic
                                ? Alignment.topLeft
                                : Alignment.topRight,
                            child: _languageButton(),
                          ),

                          const SizedBox(height: 1),

                          // -----------------------------------------------------------------
                          // LOGO
                          // -----------------------------------------------------------------

                          SizedBox(
                            height: 120,
                            child: Image.asset(
                              'assets/avatar8.png',
                              width: 168,
                              fit: BoxFit.contain,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // -----------------------------------------------------------------
                          // FORM CONTENT
                          // -----------------------------------------------------------------

                          SizedBox(
                            width: contentWidth,
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: [
                                // TITLE

                                Align(
                                  alignment: _isArabic
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Text(
                                    title,
                                    textDirection: direction,
                                    textAlign: _isArabic
                                        ? TextAlign.right
                                        : TextAlign.left,
                                    style: const TextStyle(
                                      fontFamily: 'serif',
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      color: darkBrown,
                                      height: 1.1,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // SUBTITLE

                                Align(
                                  alignment: _isArabic
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Text(
                                    subtitle,
                                    textDirection: direction,
                                    textAlign: _isArabic
                                        ? TextAlign.right
                                        : TextAlign.left,
                                    style: const TextStyle(
                                      fontFamily: 'serif',
                                      fontSize: 12,
                                      color: mutedBrown,
                                      height: 1.3,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // EMAIL

                                _input(
                                  label: emailLabel,
                                  hint: emailHint,
                                  icon: Icons.mail_outline_rounded,
                                  accent: emailAccent,
                                  controller: _emailController,
                                  validator: _validateEmail,
                                  keyboardType:
                                      TextInputType.emailAddress,
                                  textInputAction:
                                      TextInputAction.next,
                                ),

                                const SizedBox(height: 17),

                                // PASSWORD

                                _input(
                                  label: passwordLabel,
                                  hint: passwordHint,
                                  icon: Icons.lock_outline_rounded,
                                  accent: passwordAccent,
                                  controller: _passwordController,
                                  validator: _validatePassword,
                                  obscureText: _hidePassword,
                                  textInputAction:
                                      TextInputAction.done,
                                  suffix: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _hidePassword =
                                            !_hidePassword;
                                      });
                                    },
                                    splashRadius: 18,
                                    icon: Icon(
                                      _hidePassword
                                          ? Icons
                                              .visibility_off_outlined
                                          : Icons
                                              .visibility_outlined,
                                      size: 18,
                                      color: brown,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 28),

                                // LOGIN

                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed:
                                        _isLoading ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFFAE6365),
                                      foregroundColor: Colors.white,
                                      elevation: 2,
                                      shadowColor:
                                          brown.withValues(
                                        alpha: 0.20,
                                      ),
                                      shape:
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child:
                                                CircularProgressIndicator(
                                              strokeWidth: 2.2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .center,
                                            children: [
                                              Text(
                                                login,
                                                style:
                                                    const TextStyle(
                                                  fontFamily: 'serif',
                                                  fontSize: 14.5,
                                                  fontWeight:
                                                      FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 11,
                                              ),
                                              Icon(
                                                _isArabic
                                                    ? Icons
                                                        .arrow_back_rounded
                                                    : Icons
                                                        .arrow_forward_rounded,
                                                size: 19,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 14),

                                // SIGN UP

                                Align(
                                  alignment: Alignment.center,
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: const TextStyle(
                                        fontFamily: 'serif',
                                        fontSize: 13.5,
                                        color: mutedBrown,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: _isArabic
                                              ? 'ليس لديك حساب؟ '
                                              : "Don't have an account? ",
                                        ),
                                        TextSpan(
                                          text: _isArabic
                                              ? 'إنشاء حساب'
                                              : 'Sign up',
                                          style: const TextStyle(
                                            color: Color(0xFF961F1F),
                                            fontWeight:
                                                FontWeight.w700,
                                          ),
                                          recognizer:
                                              TapGestureRecognizer()
                                                ..onTap = () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          SignUpPage(
                                                        appLanguage:
                                                            widget
                                                                .appLanguage,
                                                      ),
                                                    ),
                                                  );
                                                },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}