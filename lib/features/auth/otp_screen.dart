import 'dart:async';

import 'package:farm_to_home_app/core/auth/backend_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_routes.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/network_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/email_otp_repository.dart';
import '../../data/repositories/user_repository.dart';
import 'widgets/otp_input.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.phoneNumber,
    this.email,
    this.emailVerificationSent = true,
    this.userId,
    this.source,
  });

  final String phoneNumber;
  final String? email;
  final bool emailVerificationSent;
  final String? userId;
  final String? source;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();
  final EmailOtpRepository _emailOtpRepository = EmailOtpRepository();

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  Timer? _timer;

  String? _verificationId;
  int? _resendToken;

  dynamic _webConfirmation;

  bool _sendingOtp = false;
  bool _sendingEmail = false;
  bool _verifyingOtp = false;
  bool _otpSent = false;
  bool _emailStage = true;

  int _secondsRemaining = 30;

  bool get _hasEmail => (widget.email ?? '').trim().isNotEmpty;
  String get _emailAddress => (widget.email ?? '').trim();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.emailVerificationSent) {
        setState(() {
          _otpSent = true;
        });
        _startTimer();
        _otpFocusNode.requestFocus();
      } else {
        _sendEmailOtp();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  String get _formattedPhone {
    String phone = widget.phoneNumber.trim();

    if (!phone.startsWith('+')) {
      phone = '+91$phone';
    }

    return phone;
  }

  String get _maskedPhone {
    final String phone = _formattedPhone;

    if (phone.length < 4) {
      return phone;
    }

    return '••••••${phone.substring(phone.length - 4)}';
  }

  void _startTimer() {
    _timer?.cancel();

    setState(() {
      _secondsRemaining = 30;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
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

  Future<void> _sendOtp({bool resend = false}) async {
    await _sendEmailOtp(resend: resend);
  }

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();

    final String otp = _otpController.text.trim();

    if (otp.length != 6) {
      _showMessage('Enter the complete 6-digit OTP.', error: true);
      return;
    }

    if (!_otpSent) {
      _showMessage('Please wait while OTP is being sent.', error: true);
      return;
    }

    setState(() {
      _verifyingOtp = true;
    });

    try {
      await _verifyEmailOtp(otp);
    } on BackendAuthException catch (error) {
      if (!mounted) return;

      _showMessage(_authErrorMessage(error), error: true);
    } catch (error, stackTrace) {
      debugPrint('VERIFY OTP ERROR: $error\n$stackTrace');
      if (!mounted) return;

      String errorMessage =
          _emailStage
              ? 'Email OTP verification failed. Please try again.'
              : 'OTP verification failed. Please try again.';
      if (error is NetworkException && error.message.trim().isNotEmpty) {
        errorMessage = error.message.trim();
      }

      _showMessage(errorMessage, error: true);
    } finally {
      if (mounted) {
        setState(() {
          _verifyingOtp = false;
        });
      }
    }
  }

  Future<void> _verifyWebOtp(String otp) async {
    if (_webConfirmation == null) {
      throw BackendAuthException(
        code: 'session-expired',
        message: 'OTP session expired. Please resend OTP.',
      );
    }

    await _webConfirmation.confirm(otp);

    await _markPhoneVerified();
  }

  Future<void> _verifyNativeOtp(String otp) async {
    final String? verificationId = _verificationId;

    if (verificationId == null || verificationId.isEmpty) {
      throw BackendAuthException(
        code: 'session-expired',
        message: 'OTP session expired. Please resend OTP.',
      );
    }

    final PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    await _completeNativeVerification(credential);
  }

  Future<void> _completeNativeVerification(
    PhoneAuthCredential credential,
  ) async {
    final User? user = BackendAuth.instance.currentUser;

    if (user == null) {
      throw BackendAuthException(
        code: 'user-not-found',
        message: 'Your login session expired.',
      );
    }

    await user.linkWithCredential(credential);

    await _markPhoneVerified();
  }

  Future<void> _markPhoneVerified() async {
    final User? currentUser = BackendAuth.instance.currentUser;

    if (currentUser == null) {
      throw BackendAuthException(
        code: 'user-not-found',
        message: 'Unable to verify user session.',
      );
    }

    final String uid =
        widget.userId?.trim().isNotEmpty == true
            ? widget.userId!.trim()
            : currentUser.uid;

    await currentUser.reload();
    try {
      await UserRepository().syncCurrentUser();
    } catch (_) {}

    if (!mounted) return;

    _timer?.cancel();

    _showMessage('Mobile number verified successfully.', error: false);

    final User? refreshedUser = BackendAuth.instance.currentUser;
    final bool needsEmailVerification =
        _hasEmail && !(refreshedUser?.emailVerified ?? false);

    if (needsEmailVerification) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      await _sendEmailOtp();
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 450));

    if (!mounted) return;

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.home, (Route<dynamic> route) => false);
  }

  Future<void> _sendEmailOtp({bool resend = false}) async {
    if (_sendingEmail || _verifyingOtp || !_hasEmail) {
      return;
    }

    setState(() {
      _sendingEmail = true;
      _emailStage = true;
      _otpSent = false;
    });

    _otpController.clear();

    try {
      final User? currentUser = BackendAuth.instance.currentUser;
      final Map<String, dynamic> result =
          currentUser != null
              ? await _emailOtpRepository.sendOtp(_emailAddress)
              : await _emailOtpRepository.requestOtp(_emailAddress);

      if (!mounted) return;

      final bool alreadyVerified = result['alreadyVerified'] == true;

      if (alreadyVerified) {
        await BackendAuth.instance.currentUser?.reload();
        await UserRepository().syncCurrentUser();

        if (!mounted) return;

        _showMessage('Your email address is already verified.', error: false);

        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.home,
          (Route<dynamic> route) => false,
        );
        return;
      }

      setState(() {
        _otpSent = true;
      });

      _startTimer();
      _otpFocusNode.requestFocus();

      _showMessage(
        resend
            ? 'A new email OTP was sent successfully.'
            : 'Email OTP sent successfully.',
        error: false,
      );
    } catch (error, stackTrace) {
      debugPrint('SEND EMAIL OTP ERROR: $error\n$stackTrace');

      if (!mounted) return;

      setState(() {
        _otpSent = false;
      });

      String errorMessage =
          'Unable to send email OTP. Check SMTP setup and try again.';
      if (error is NetworkException && error.message.trim().isNotEmpty) {
        errorMessage = error.message.trim();
      } else if (error is AppException && error.message.trim().isNotEmpty) {
        errorMessage = error.message.trim();
      }

      _showMessage(errorMessage, error: true);
    } finally {
      if (mounted) {
        setState(() {
          _sendingEmail = false;
        });
      }
    }
  }

  Future<void> _verifyEmailOtp(String otp) async {
    final User? currentUser = BackendAuth.instance.currentUser;
    if (currentUser != null) {
      await _emailOtpRepository.verifyOtp(otp, _emailAddress);
      await currentUser.reload();
      try {
        await UserRepository().syncCurrentUser();
      } catch (_) {}
    } else {
      await _emailOtpRepository.verifyResetOtp(_emailAddress, otp);
    }

    if (!mounted) return;

    _timer?.cancel();

    _showMessage('Email verified successfully.', error: false);

    await Future<void>.delayed(const Duration(milliseconds: 450));

    if (!mounted) return;

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.home, (Route<dynamic> route) => false);
  }

  Future<void> _resendOtp() async {
    if (_secondsRemaining > 0 ||
        _sendingOtp ||
        _sendingEmail ||
        _verifyingOtp) {
      return;
    }

    _otpController.clear();

    await _sendEmailOtp(resend: true);
  }

  void _changePhoneNumber() {
    if (_sendingOtp || _sendingEmail || _verifyingOtp) {
      return;
    }

    if (widget.source == 'register') {
      Navigator.of(context).pushReplacementNamed(AppRoutes.register);
      return;
    }

    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  String _authErrorMessage(BackendAuthException error) {
    switch (error.code) {
      case 'invalid-verification-code':
        return 'Incorrect OTP. Please try again.';

      case 'session-expired':
        return 'OTP expired. Please resend OTP.';

      case 'invalid-phone-number':
        return 'Enter a valid mobile number.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'quota-exceeded':
        return 'OTP request limit exceeded. Please try again later.';

      case 'credential-already-in-use':
        return 'This account detail is already linked to another account.';

      case 'network-request-failed':
        return 'Check your internet connection and try again.';

      default:
        return error.message ?? 'OTP verification failed.';
    }
  }

  void _showMessage(String message, {required bool error}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: error ? AppColors.error : AppColors.primary,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Row(
            children: <Widget>[
              Icon(
                error
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

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const _OtpBackground(),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: width >= 700 ? 28 : 18,
                vertical: 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _buildTopBar(),

                          const SizedBox(height: 32),

                          _buildOtpCard(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildTopBar() {
    return Row(
      children: <Widget>[
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap:
                _sendingOtp || _sendingEmail || _verifyingOtp
                    ? null
                    : _changePhoneNumber,
            child: const SizedBox(
              width: 46,
              height: 46,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Text(
          'Verify OTP',
          style: TextStyle(
            color: Color(0xFF257A3E),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildOtpCard() {
    final String maskedEmail = _maskEmail(_emailAddress);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 36,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF6ED),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.mark_email_read_rounded,
                color: Color(0xFF257A3E),
                size: 42,
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Enter Verification Code',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            _hasEmail
                ? 'We sent a 6-digit verification OTP code to\n$maskedEmail'
                : 'We sent a 6-digit verification OTP code',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 28),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F5F4),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE1E7E3)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4EBE6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.onetwothree_rounded,
                    color: Color(0xFF257A3E),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: OtpInput(
                    child: TextField(
                      controller: _otpController,
                      focusNode: _otpFocusNode,
                      enabled: !_verifyingOtp,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      maxLength: 6,
                      autofillHints: const <String>[AutofillHints.oneTimeCode],
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      onSubmitted: (_) => _verifyOtp(),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                      ),
                      decoration: const InputDecoration(
                        counterText: '',
                        hintText: '6-Digit OTP Code',
                        hintStyle: TextStyle(
                          color: Color(0xFF9EABA2),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
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

          const SizedBox(height: 24),

          SizedBox(
            height: 56,
            child: FilledButton(
              onPressed:
                  _verifyingOtp || _sendingOtp || _sendingEmail
                      ? null
                      : _verifyOtp,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF257A3E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child:
                  _verifyingOtp
                      ? const SizedBox(
                        width: 23,
                        height: 23,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                      : const Text(
                        'VERIFY OTP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child:
                _secondsRemaining > 0
                    ? Text(
                      'Resend OTP in ${_secondsRemaining}s',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                    : TextButton(
                      onPressed:
                          _sendingOtp || _sendingEmail || _verifyingOtp
                              ? null
                              : _resendOtp,
                      child: const Text(
                        'Resend OTP',
                        style: TextStyle(
                          color: Color(0xFF257A3E),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
          ),

          const SizedBox(height: 8),

          Center(
            child: TextButton(
              onPressed:
                  _sendingOtp || _sendingEmail || _verifyingOtp
                      ? null
                      : _changePhoneNumber,
              child: const Text(
                'Use another email address',
                style: TextStyle(
                  color: Color(0xFF257A3E),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpBackground extends StatelessWidget {
  const _OtpBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color(0xFFE8F5E9),
                  Color(0xFFFFFBF2),
                  AppColors.background,
                ],
              ),
            ),
          ),
        ),

        Positioned(
          top: -120,
          right: -100,
          child: Container(
            width: 350,
            height: 350,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x100B7A3E),
            ),
          ),
        ),

        Positioned(
          bottom: -120,
          left: -100,
          child: Container(
            width: 320,
            height: 320,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x10F4B400),
            ),
          ),
        ),
      ],
    );
  }
}
