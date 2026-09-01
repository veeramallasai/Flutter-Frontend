import 'dart:async';

import 'package:farm_to_home_app/core/auth/backend_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_routes.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/network_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/email_otp_repository.dart';
import '../../data/repositories/user_repository.dart';
import 'widgets/otp_input.dart';
import 'widgets/password_strength.dart';
import 'widgets/register_form.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _loading = false;
  bool _termsAccepted = false;

  int _currentStep = 1; // 1 = DETAILS, 2 = VERIFY OTP, 3 = FRESH
  bool _verifyingOtp = false;
  bool _sendingOtp = false;
  int _secondsRemaining = 45;
  Timer? _otpTimer;

  @override
  void dispose() {
    _otpTimer?.cancel();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _startOtpTimer() {
    _otpTimer?.cancel();
    setState(() {
      _secondsRemaining = 45;
    });
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() {
          _secondsRemaining = 0;
        });
        return;
      }
      setState(() {
        _secondsRemaining--;
      });
    });
  }

  String _normalizePhone(String value) {
    String digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.startsWith('91') && digits.length == 12) {
      digits = digits.substring(2);
    }

    return digits;
  }

  String? _validateFirstName(String? value) {
    final String text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Enter your first name';
    }

    if (text.length < 2) {
      return 'Enter a valid first name';
    }

    return null;
  }

  String? _validateLastName(String? value) {
    final String text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Enter your last name';
    }

    if (text.length < 2) {
      return 'Enter a valid last name';
    }

    return null;
  }

  String? _validatePhone(String? value) {
    final String raw = value?.trim() ?? '';
    if (raw.isEmpty) return null;
    final String phone = _normalizePhone(raw);
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(phone)) {
      return 'Enter a valid 10-digit mobile number or leave it blank';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final String email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Enter your email address';
    }

    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final String password = value ?? '';

    if (password.length < 8) {
      return 'Password must contain at least 8 characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Add at least one uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Add at least one lowercase letter';
    }

    if (!RegExp(r'\d').hasMatch(password)) {
      return 'Add at least one number';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Confirm your password';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  Future<UserCredential> _createOrResumeUser({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final UserCredential credential = await BackendAuth.instance
          .createUserWithEmailAndPassword(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
          );

      if (credential.user == null) {
        throw BackendAuthException(
          code: 'registration-failed',
          message: 'Unable to create your account.',
        );
      }

      return credential;
    } on BackendAuthException catch (error) {
      if (error.code != 'email-already-in-use') {
        rethrow;
      }

      final UserCredential credential = await BackendAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (credential.user == null) {
        throw BackendAuthException(
          code: 'registration-failed',
          message: 'Unable to resume account setup.',
        );
      }

      return credential;
    }
  }

  Future<void> _completeProfileSetup(
    User user,
    String firstName,
    String lastName,
  ) async {
    try {
      final String displayName = '$firstName $lastName'.trim();
      await user.updateDisplayName(displayName);
      await user.reload();
    } catch (error) {
      debugPrint('REGISTER DISPLAY NAME UPDATE WARNING: $error');
    }

    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        await UserRepository().syncCurrentUser();
        return;
      } catch (error) {
        if (attempt < 3) {
          await Future<void>.delayed(Duration(milliseconds: 300 * attempt));
        }
      }
    }
  }

  void _openOtpScreen({
    required String email,
    required String phone,
    required bool emailSent,
    required String userId,
  }) {
    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(
      AppRoutes.otp,
      arguments: <String, dynamic>{
        'phoneNumber': phone,
        'email': email,
        'emailVerificationSent': emailSent,
        'userId': userId,
        'source': 'register-email-only',
      },
    );
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (!_termsAccepted) {
      _showMessage(
        'Please accept Terms of Service and Privacy Policy.',
        isError: true,
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    final String firstName = _firstNameController.text.trim();
    final String lastName = _lastNameController.text.trim();
    final String email = _emailController.text.trim().toLowerCase();
    final String phoneDigits = _normalizePhone(_phoneController.text);
    final String phone = phoneDigits.isEmpty ? '' : '+91$phoneDigits';
    final String password = _passwordController.text;

    UserCredential credential;
    try {
      credential = await _createOrResumeUser(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
    } on BackendAuthException catch (error) {
      final String message = (error.message ?? '').toLowerCase();
      final bool verificationPending =
          error.code == 'authentication-pending' ||
          (message.contains('registration successful') &&
              message.contains('otp'));
      if (verificationPending) {
        _openOtpScreen(
          email: email,
          phone: phone,
          emailSent: true,
          userId: email,
        );
        return;
      }
      if (mounted) {
        _showMessage(_authErrorMessage(error), isError: true);
        setState(() => _loading = false);
      }
      return;
    } catch (error) {
      if (mounted) {
        String msg = 'Unable to create account. Please try again.';
        if (error is AppException && error.message.trim().isNotEmpty) {
          msg = error.message.trim();
        } else if (error is NetworkException &&
            error.message.trim().isNotEmpty) {
          msg = error.message.trim();
        }
        _showMessage(msg, isError: true);
        setState(() => _loading = false);
      }
      return;
    }

    final User user = credential.user!;
    bool emailSent = credential.emailVerificationSent;
    if (!emailSent) {
      try {
        final EmailOtpRepository emailOtpRepo = EmailOtpRepository();
        await emailOtpRepo.sendOtp(email);
        emailSent = true;
      } catch (error) {
        debugPrint('REGISTER EMAIL OTP SEND WARNING: $error');
      }
    }

    if (!mounted) return;

    _openOtpScreen(
      email: email,
      phone: phone,
      emailSent: emailSent,
      userId: user.uid,
    );
    if (!credential.authenticationPending) {
      unawaited(_completeProfileSetup(user, firstName, lastName));
    }
  }

  Future<void> _verifyStep2Otp() async {
    FocusScope.of(context).unfocus();

    final String otp = _otpController.text.trim();
    if (otp.length != 6) {
      _showMessage('Enter the complete 6-digit OTP code.', isError: true);
      return;
    }

    setState(() {
      _verifyingOtp = true;
    });

    final String email = _emailController.text.trim().toLowerCase();

    try {
      final EmailOtpRepository emailOtpRepo = EmailOtpRepository();
      final User? currentUser = BackendAuth.instance.currentUser;

      if (currentUser != null) {
        await emailOtpRepo.verifyOtp(otp, email);
        await currentUser.reload();
        try {
          await UserRepository().syncCurrentUser();
        } catch (_) {}
      } else {
        await emailOtpRepo.verifyResetOtp(email, otp);
      }

      if (!mounted) return;

      _otpTimer?.cancel();
      setState(() {
        _currentStep = 3;
      });

      _showMessage('Email verified successfully.', isError: false);

      await Future<void>.delayed(const Duration(milliseconds: 450));

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (Route<dynamic> route) => false,
      );
    } on BackendAuthException catch (error) {
      if (!mounted) return;

      _showMessage(_authErrorMessage(error), isError: true);
    } catch (error) {
      debugPrint('VERIFY STEP 2 OTP ERROR: $error');
      if (!mounted) return;

      String message = 'OTP verification failed. Please try again.';
      if (error is NetworkException && error.message.trim().isNotEmpty) {
        message = error.message.trim();
      } else if (error is AppException && error.message.trim().isNotEmpty) {
        message = error.message.trim();
      }

      _showMessage(message, isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _verifyingOtp = false;
        });
      }
    }
  }

  Future<void> _resendStep2Otp() async {
    if (_secondsRemaining > 0 || _sendingOtp || _verifyingOtp) return;

    setState(() {
      _sendingOtp = true;
    });

    _otpController.clear();
    final String email = _emailController.text.trim().toLowerCase();

    try {
      final EmailOtpRepository emailOtpRepo = EmailOtpRepository();
      await emailOtpRepo.sendOtp(email);

      if (!mounted) return;

      _startOtpTimer();
      _otpFocusNode.requestFocus();
      _showMessage('A new OTP code was sent to your email.', isError: false);
    } catch (error) {
      if (!mounted) return;
      _showMessage(
        'Unable to send email OTP. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _sendingOtp = false;
        });
      }
    }
  }

  String _authErrorMessage(BackendAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'This email already has an account. Use the same password to continue setup.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'This email already has an account, but the password is incorrect.';

      case 'invalid-email':
        return 'Enter a valid email address.';

      case 'weak-password':
        return 'Please choose a stronger password.';

      case 'network-request-failed':
        return 'Check your internet connection and try again.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'operation-not-allowed':
        return 'Email/Password authentication is currently unavailable.';

      default:
        return error.message ?? 'Registration failed.';
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? AppColors.error : const Color(0xFF257A3E),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Row(
            children: <Widget>[
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  void _goLogin() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final bool desktop = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFFE7F5EC),
              Color(0xFFFFFBF2),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.symmetric(
              horizontal: desktop ? 28 : 16,
              vertical: 18,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1050),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _buildHeader(),

                    const SizedBox(height: 20),

                    if (desktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Expanded(flex: 4, child: _RegisterHero()),

                          const SizedBox(width: 20),

                          Expanded(flex: 6, child: _buildForm()),
                        ],
                      )
                    else ...<Widget>[
                      const _RegisterHero(),

                      const SizedBox(height: 18),

                      _buildForm(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: <Widget>[
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: _loading ? null : _goLogin,
            child: const SizedBox(
              width: 45,
              height: 45,
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
          ),
        ),

        const SizedBox(width: 12),

        const Text(
          'Farm To Home',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 34,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: RegisterForm(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _currentStep == 2
                          ? 'Verify Email OTP'
                          : 'Join Fresh Club',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.shield_rounded,
                          color: AppColors.primary,
                          size: 14,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'SECURE',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                _currentStep == 2
                    ? 'Enter the 6-digit verification code sent to your email.'
                    : 'One account for fresh home shopping and business bulk orders.',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 17),

              _RegistrationSteps(currentStep: _currentStep),

              const SizedBox(height: 20),

              if (_currentStep == 2)
                _buildStep2OtpView()
              else ...<Widget>[
                TextFormField(
                  controller: _firstNameController,
                  enabled: !_loading,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: _validateFirstName,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    prefixIcon: Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: _lastNameController,
                  enabled: !_loading,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: _validateLastName,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    prefixIcon: Icon(
                      Icons.badge_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: _phoneController,
                  enabled: !_loading,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: _validatePhone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '9876543210',
                    prefixText: '+91  ',
                    prefixIcon: Icon(
                      Icons.phone_iphone_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: _emailController,
                  enabled: !_loading,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _validateEmail,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'name@example.com',
                    prefixIcon: Icon(
                      Icons.alternate_email_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: _passwordController,
                  enabled: !_loading,
                  obscureText: _hidePassword,
                  textInputAction: TextInputAction.next,
                  validator: _validatePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.primary,
                    ),
                    suffixIcon: IconButton(
                      onPressed:
                          _loading
                              ? null
                              : () {
                                setState(() {
                                  _hidePassword = !_hidePassword;
                                });
                              },
                      icon: Icon(
                        _hidePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                ),

                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _passwordController,
                  builder:
                      (
                        BuildContext context,
                        TextEditingValue value,
                        Widget? child,
                      ) => PasswordStrength(password: value.text),
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller: _confirmPasswordController,
                  enabled: !_loading,
                  obscureText: _hideConfirmPassword,
                  textInputAction: TextInputAction.done,
                  validator: _validateConfirmPassword,
                  onFieldSubmitted: (_) {
                    if (!_loading) {
                      _register();
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(
                      Icons.verified_user_outlined,
                      color: AppColors.primary,
                    ),
                    suffixIcon: IconButton(
                      onPressed:
                          _loading
                              ? null
                              : () {
                                setState(() {
                                  _hideConfirmPassword = !_hideConfirmPassword;
                                });
                              },
                      icon: Icon(
                        _hideConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Material(
                  color: Colors.transparent,
                  child: CheckboxListTile(
                    value: _termsAccepted,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text(
                      'I agree to the Terms of Service and Privacy Policy.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onChanged:
                        _loading
                            ? null
                            : (bool? value) {
                              setState(() {
                                _termsAccepted = value ?? false;
                              });
                            },
                  ),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: _loading ? null : _register,
                    child:
                        _loading
                            ? const SizedBox(
                              width: 23,
                              height: 23,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                            : const Text('CREATE MY FRESH ACCOUNT'),
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'Already have an account?',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: _loading ? null : _goLogin,
                      child: const Text(
                        'Login',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep2OtpView() {
    final String maskedEmail = _maskEmail(_emailController.text.trim());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 10),

        // Green Mail check icon container matching reference design
        Center(
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6ED),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.mark_email_read_rounded,
              color: AppColors.primary,
              size: 38,
            ),
          ),
        ),

        const SizedBox(height: 22),

        // Title
        const Text(
          'Enter Verification Code',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          'We sent a 6-digit verification OTP code to\n$maskedEmail',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13.5,
            height: 1.45,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 28),

        // Custom Outlined 6-Digit OTP Field matching reference design
        Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Container(
              height: 62,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: Row(
                children: <Widget>[
                  // 123 Icon badge on left
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.onetwothree_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // OTP text field
                  Expanded(
                    child: OtpInput(
                      child: TextField(
                        controller: _otpController,
                        focusNode: _otpFocusNode,
                        enabled: !_verifyingOtp && !_sendingOtp,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        maxLength: 6,
                        autofillHints: const <String>[
                          AutofillHints.oneTimeCode,
                        ],
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        onSubmitted: (_) => _verifyStep2Otp(),
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 14,
                        ),
                        decoration: const InputDecoration(
                          counterText: '',
                          hintText: '1 2 3 4 5 6',
                          hintStyle: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 10,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Floating notch label on top border line
            Positioned(
              top: -9,
              left: 20,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: const Text(
                  '6-Digit OTP Code',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // VERIFY OTP button
        SizedBox(
          height: 54,
          child: FilledButton(
            onPressed: _verifyingOtp || _sendingOtp ? null : _verifyStep2Otp,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child:
                _verifyingOtp
                    ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                    : const Text(
                      'VERIFY OTP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
          ),
        ),

        const SizedBox(height: 20),

        // Resend Timer / Resend Action
        Center(
          child:
              _secondsRemaining > 0
                  ? Text(
                    'Resend OTP in ${_secondsRemaining}s',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                  : TextButton(
                    onPressed:
                        _sendingOtp || _verifyingOtp ? null : _resendStep2Otp,
                    child: const Text(
                      'Resend OTP',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
        ),

        const SizedBox(height: 4),

        // Edit account details / Use another email link
        Center(
          child: TextButton(
            onPressed:
                _verifyingOtp || _sendingOtp
                    ? null
                    : () {
                      _otpTimer?.cancel();
                      setState(() {
                        _currentStep = 1;
                      });
                    },
            child: const Text(
              'Use another email address',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _maskEmail(String email) {
    final String clean = email.trim();
    if (clean.isEmpty || !clean.contains('@')) return clean;

    final List<String> parts = clean.split('@');
    final String username = parts[0];
    final String domain = parts[1];

    if (username.length <= 2) {
      return '${username.substring(0, 1)}***@$domain';
    }

    return '${username.substring(0, 2)}***@$domain';
  }
}

class _RegisterHero extends StatelessWidget {
  const _RegisterHero();

  @override
  Widget build(BuildContext context) {
    final bool compact = MediaQuery.sizeOf(context).width < 900;
    return Container(
      constraints: BoxConstraints(minHeight: compact ? 215 : 430),
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF1B5E20),
            Color(0xFF0B6F3B),
            Color(0xFF25A75D),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const CircleAvatar(
            radius: 33,
            backgroundColor: Colors.white,
            child: Icon(Icons.eco_rounded, color: AppColors.primary, size: 38),
          ),

          // This screen lives inside a vertical SingleChildScrollView. A
          // Spacer here receives an unbounded height on desktop/web and
          // triggers a RenderFlex runtime exception, leaving a blank page.
          SizedBox(height: compact ? 24 : 150),

          Text(
            'Fresh food.\nTrusted farms.',
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 26 : 34,
              height: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Retail shopping for home and bulk ordering for shop owners — all in one account.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _HeroPill(Icons.verified_rounded, 'Quality checked'),
              _HeroPill(Icons.lock_rounded, 'Secure account'),
              _HeroPill(Icons.local_shipping_rounded, 'Live delivery'),
            ],
          ),
        ],
      ),
    );
  }
}

class _RegistrationSteps extends StatelessWidget {
  const _RegistrationSteps({this.currentStep = 1});

  final int currentStep;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF6FAF7),
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: const Color(0xFFE2ECE6)),
    ),
    child: Row(
      children: <Widget>[
        _StepDot(number: '1', label: 'DETAILS', active: currentStep >= 1),
        Expanded(
          child: Divider(
            color:
                currentStep >= 2 ? AppColors.primary : const Color(0xFFC7D9CF),
            indent: 7,
            endIndent: 7,
          ),
        ),
        _StepDot(number: '2', label: 'VERIFY', active: currentStep >= 2),
        Expanded(
          child: Divider(
            color:
                currentStep >= 3 ? AppColors.primary : const Color(0xFFC7D9CF),
            indent: 7,
            endIndent: 7,
          ),
        ),
        _StepDot(number: '3', label: 'FRESH', active: currentStep >= 3),
      ],
    ),
  );
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.number,
    required this.label,
    this.active = false,
  });
  final String number;
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: active ? AppColors.primary : const Color(0xFFC7D9CF),
          ),
        ),
        child: Text(
          number,
          style: TextStyle(
            color: active ? Colors.white : AppColors.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: TextStyle(
          color: active ? AppColors.primary : AppColors.textSecondary,
          fontSize: 7,
          fontWeight: FontWeight.w900,
        ),
      ),
    ],
  );
}

class _HeroPill extends StatelessWidget {
  const _HeroPill(this.icon, this.label);
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, color: const Color(0xFFFFB300), size: 13),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}
