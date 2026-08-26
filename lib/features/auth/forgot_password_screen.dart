import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_routes.dart';
import '../../core/auth/backend_auth.dart';
import '../../core/errors/network_exception.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/password_strength.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _step1FormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _step2FormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _step3FormKey = GlobalKey<FormState>();

  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FocusNode _identifierFocusNode = FocusNode();
  final FocusNode _otpFocusNode = FocusNode();
  final FocusNode _newPasswordFocusNode = FocusNode();

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  /// Flow step: 1 = Request OTP, 2 = Verify OTP, 3 = Reset Password, 4 = Success
  int _step = 1;

  bool _loading = false;
  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;

  String _resolvedEmail = '';
  String _verifiedOtp = '';

  Timer? _cooldownTimer;
  int _resendCooldownSeconds = 0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
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
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _animationController.dispose();
    _identifierController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _identifierFocusNode.dispose();
    _otpFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    super.dispose();
  }

  void _startResendCooldown([int seconds = 60]) {
    _cooldownTimer?.cancel();
    setState(() {
      _resendCooldownSeconds = seconds;
    });

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCooldownSeconds <= 1) {
        timer.cancel();
        setState(() {
          _resendCooldownSeconds = 0;
        });
      } else {
        setState(() {
          _resendCooldownSeconds--;
        });
      }
    });
  }

  String? _validateIdentifier(String? value) {
    final String input = value?.trim() ?? '';
    if (input.isEmpty) {
      return 'Enter your email address';
    }
    final bool validEmail = RegExp(
      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
    ).hasMatch(input);
    if (!validEmail) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validateOtp(String? value) {
    final String otp = value?.trim() ?? '';
    if (otp.isEmpty) {
      return 'Enter the 6-digit OTP code';
    }
    if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
      return 'OTP must be exactly 6 digits';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    final String password = value ?? '';
    if (password.isEmpty) {
      return 'Enter your new password';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(password)) {
      return 'Include at least one letter';
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      return 'Include at least one number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Confirm your new password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // --- STEP 1: SEND OTP ---
  Future<void> _sendOtp({bool isResend = false}) async {
    FocusScope.of(context).unfocus();

    if (!isResend && !(_step1FormKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final String email = _identifierController.text.trim().toLowerCase();
      await BackendAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      setState(() {
        _resolvedEmail = email;
        _step = 2;
      });

      _startResendCooldown(60);
      _showMessage(
        isResend
            ? 'New OTP dispatched to your email.'
            : 'Verification OTP sent to your email.',
        isError: false,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _otpFocusNode.requestFocus();
        }
      });
    } catch (error, stackTrace) {
      debugPrint('SEND RESET OTP ERROR: $error\n$stackTrace');
      if (!mounted) return;

      String message = 'Unable to send OTP. Check connection and try again.';
      if (error is NetworkException && error.message.trim().isNotEmpty) {
        message = error.message.trim();
      }

      _showMessage(message, isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // --- STEP 2: VERIFY OTP ---
  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();

    if (!(_step2FormKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _loading = true;
    });

    final String otp = _otpController.text.trim();

    try {
      await BackendAuth.instance.verifyResetOtp(
        email: _resolvedEmail,
        otpCode: otp,
      );

      if (!mounted) return;

      setState(() {
        _verifiedOtp = otp;
        _step = 3;
      });

      _showMessage('OTP verified! Create your new password.', isError: false);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _newPasswordFocusNode.requestFocus();
        }
      });
    } catch (error, stackTrace) {
      debugPrint('VERIFY OTP ERROR: $error\n$stackTrace');
      if (!mounted) return;

      String message = 'Invalid or expired OTP code. Please try again.';
      if (error is NetworkException && error.message.trim().isNotEmpty) {
        message = error.message.trim();
      }

      _showMessage(message, isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // --- STEP 3: RESET PASSWORD ---
  Future<void> _resetPassword() async {
    FocusScope.of(context).unfocus();

    if (!(_step3FormKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await BackendAuth.instance.resetPassword(
        email: _resolvedEmail,
        otpCode: _verifiedOtp,
        newPassword: _newPasswordController.text,
      );

      if (!mounted) return;

      setState(() {
        _step = 4;
      });

      _showMessage('Password reset successfully!', isError: false);
    } catch (error, stackTrace) {
      debugPrint('RESET PASSWORD ERROR: $error\n$stackTrace');
      if (!mounted) return;

      String message = 'Unable to reset password. Please try again.';
      if (error is NetworkException && error.message.trim().isNotEmpty) {
        message = error.message.trim();
      }

      _showMessage(message, isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  String _maskEmail(String email) {
    final List<String> parts = email.split('@');
    if (parts.length != 2 || parts.first.isEmpty) {
      return email;
    }
    final String name = parts.first;
    final String domain = parts.last;
    if (name.length <= 2) {
      return '${name.substring(0, 1)}***@$domain';
    }
    return '${name.substring(0, 2)}***@$domain';
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? AppColors.error : AppColors.primary,
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

  void _goToLogin() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  void _resetToStep1() {
    setState(() {
      _step = 1;
      _resolvedEmail = '';
      _verifiedOtp = '';
      _otpController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _identifierFocusNode.requestFocus();
      }
    });
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
          const _ForgotPasswordBackground(),
          SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(
                horizontal: width >= 700 ? 28 : 18,
                vertical: 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _buildTopBar(),
                          const SizedBox(height: 28),
                          _buildActiveStepCard(),
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
            onTap: _loading ? null : _goToLogin,
            child: const SizedBox(
              width: 46,
              height: 46,
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          _step == 1
              ? 'Forgot Password'
              : _step == 2
                  ? 'Verify OTP'
                  : _step == 3
                      ? 'New Password'
                      : 'Password Reset Complete',
          style: const TextStyle(
            color: AppColors.primaryDark,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveStepCard() {
    Widget content;
    switch (_step) {
      case 1:
        content = _buildStep1RequestOtpCard();
        break;
      case 2:
        content = _buildStep2VerifyOtpCard();
        break;
      case 3:
        content = _buildStep3NewPasswordCard();
        break;
      case 4:
      default:
        content = _buildStep4SuccessCard();
        break;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x16000000),
                blurRadius: 40,
                offset: Offset(0, 18),
              ),
            ],
          ),
          child: content,
        ),
      ),
    );
  }

  // STEP 1 CARD: Request OTP
  Widget _buildStep1RequestOtpCard() {
    return Form(
      key: _step1FormKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[Color(0xFF2E7D32), Color(0xFF23A559)],
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x300B7A3E),
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Reset your password',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Enter your registered email address. We will send a 6-digit OTP code to verify your identity.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.5,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: _identifierController,
              focusNode: _identifierFocusNode,
              enabled: !_loading,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const <String>[
                AutofillHints.username,
                AutofillHints.email,
              ],
              validator: _validateIdentifier,
              onFieldSubmitted: (_) {
                if (!_loading) _sendOtp();
              },
              decoration: const InputDecoration(
                labelText: 'Email address',
                hintText: 'name@example.com',
                prefixIcon: Icon(
                  Icons.mail_outline_rounded,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: _loading ? null : () => _sendOtp(),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text('SEND OTP'),
              ),
            ),
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: _loading ? null : _goToLogin,
              icon: const Icon(Icons.login_rounded, size: 19),
              label: const Text(
                'Back to Login',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 2 CARD: Verify 6-digit OTP
  Widget _buildStep2VerifyOtpCard() {
    return Form(
      key: _step2FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF8EF),
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(
                Icons.mark_email_read_outlined,
                color: AppColors.primary,
                size: 44,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Enter Verification Code',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'We sent a 6-digit verification OTP code to\n${_maskEmail(_resolvedEmail)}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.5,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 28),
          TextFormField(
            controller: _otpController,
            focusNode: _otpFocusNode,
            enabled: !_loading,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 14,
              color: AppColors.primaryDark,
            ),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            validator: _validateOtp,
            onFieldSubmitted: (_) {
              if (!_loading) _verifyOtp();
            },
            decoration: const InputDecoration(
              labelText: '6-Digit OTP Code',
              hintText: '123456',
              counterText: '',
              prefixIcon: Icon(
                Icons.pin_outlined,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: _loading ? null : _verifyOtp,
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text('VERIFY OTP'),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _resendCooldownSeconds > 0
                    ? 'Resend OTP in ${_resendCooldownSeconds}s'
                    : "Didn't receive code?",
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              if (_resendCooldownSeconds == 0)
                TextButton(
                  onPressed: _loading ? null : () => _sendOtp(isResend: true),
                  child: const Text(
                    'Resend OTP',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          TextButton(
            onPressed: _loading ? null : _resetToStep1,
            child: const Text(
              'Use another email address',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 3 CARD: New Password & Confirm Password
  Widget _buildStep3NewPasswordCard() {
    return Form(
      key: _step3FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF8EF),
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(
                Icons.published_with_changes_rounded,
                color: AppColors.primary,
                size: 44,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Create New Password',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your OTP was verified successfully. Please choose a new strong password for your account.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 26),
          TextFormField(
            controller: _newPasswordController,
            focusNode: _newPasswordFocusNode,
            enabled: !_loading,
            obscureText: _hideNewPassword,
            textInputAction: TextInputAction.next,
            validator: _validateNewPassword,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'New password',
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.primary,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _hideNewPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _hideNewPassword = !_hideNewPassword;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          PasswordStrength(password: _newPasswordController.text),
          const SizedBox(height: 18),
          TextFormField(
            controller: _confirmPasswordController,
            enabled: !_loading,
            obscureText: _hideConfirmPassword,
            textInputAction: TextInputAction.done,
            validator: _validateConfirmPassword,
            onFieldSubmitted: (_) {
              if (!_loading) _resetPassword();
            },
            decoration: InputDecoration(
              labelText: 'Confirm new password',
              prefixIcon: const Icon(
                Icons.lock_clock_outlined,
                color: AppColors.primary,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _hideConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _hideConfirmPassword = !_hideConfirmPassword;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: _loading ? null : _resetPassword,
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text('RESET PASSWORD'),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 4 CARD: Reset Success
  Widget _buildStep4SuccessCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: Container(
            width: 94,
            height: 94,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF8EF),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.primary,
              size: 52,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Password Reset Complete!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Your account password has been reset successfully. You can now log in using your new credentials.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          height: 54,
          child: FilledButton(
            onPressed: _goToLogin,
            child: const Text('BACK TO LOGIN'),
          ),
        ),
      ],
    );
  }
}

class _ForgotPasswordBackground extends StatelessWidget {
  const _ForgotPasswordBackground();

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
