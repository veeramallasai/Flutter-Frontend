import 'dart:async';

import 'package:farm_to_home_app/core/auth/backend_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_routes.dart';
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
      _sendEmailOtp();
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
              ? await _emailOtpRepository.sendOtp()
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
      await _emailOtpRepository.verifyOtp(otp);
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
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          _emailStage ? 'Verify Email' : 'Verify Email',
          style: const TextStyle(
            color: AppColors.primaryDark,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildOtpCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 40,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[Color(0xFF2E7D32), Color(0xFF23A559)],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x300B7A3E),
                    blurRadius: 26,
                    offset: Offset(0, 13),
                  ),
                ],
              ),
              child: Icon(
                _emailStage
                    ? Icons.mark_email_read_outlined
                    : Icons.sms_outlined,
                color: Colors.white,
                size: 42,
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Email OTP Verification',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            _emailStage
                ? (_sendingEmail && !_otpSent
                    ? 'Sending email OTP to $_emailAddress...'
                    : 'Enter the 6-digit code sent to $_emailAddress')
                : (_sendingOtp && !_otpSent
                    ? 'Sending OTP to $_formattedPhone...'
                    : 'Enter the 6-digit code sent to $_maskedPhone'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),

          if (_emailStage) ...<Widget>[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1DEAE)),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.email_outlined, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'A 6-digit verification code was sent to $_emailAddress. No mobile SMS OTP is required.',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.5,
                        height: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 28),

          OtpInput(
            child: TextField(
              controller: _otpController,
              focusNode: _otpFocusNode,
              enabled: !_verifyingOtp,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              textAlign: TextAlign.center,
              maxLength: 6,
              autofillHints: const <String>[AutofillHints.oneTimeCode],
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              onSubmitted: (_) {
                _verifyOtp();
              },
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 27,
                letterSpacing: 10,
                fontWeight: FontWeight.w900,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: '••••••',
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 22,
                  horizontal: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            height: 56,
            child: FilledButton(
              onPressed:
                  _verifyingOtp || _sendingOtp || _sendingEmail
                      ? null
                      : _verifyOtp,
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
                      : const Text('VERIFY & CONTINUE'),
            ),
          ),

          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                "Didn't receive OTP?",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(width: 6),

              if (_secondsRemaining > 0)
                Text(
                  '${_secondsRemaining}s',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                )
              else
                TextButton(
                  onPressed: _sendingOtp || _verifyingOtp ? null : _resendOtp,
                  child: const Text(
                    'Resend OTP',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
            ],
          ),

          if (false)
            TextButton.icon(
              onPressed:
                  _sendingOtp || _sendingEmail || _verifyingOtp
                      ? null
                      : _changePhoneNumber,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text(
                'Change mobile number',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDCEFE4)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),

                SizedBox(width: 10),

                Expanded(
                  child: Text(
                    'Never share your OTP with anyone. Farm To Home will never ask for your OTP by phone or message.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
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
