import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/theme/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _identifierController =
  TextEditingController();

  final FocusNode _identifierFocusNode = FocusNode();

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _loading = false;
  bool _emailSent = false;

  String _resolvedEmail = '';

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
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _identifierController.dispose();
    _identifierFocusNode.dispose();
    super.dispose();
  }

  String _normalizePhone(String input) {
    String digits = input.replaceAll(
      RegExp(r'\D'),
      '',
    );

    if (digits.startsWith('91') &&
        digits.length == 12) {
      digits = digits.substring(2);
    }

    return digits;
  }

  String? _validateIdentifier(
      String? value,
      ) {
    final String input =
        value?.trim() ?? '';

    if (input.isEmpty) {
      return 'Enter your email or mobile number';
    }

    if (input.contains('@')) {
      final bool validEmail =
      RegExp(
        r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
      ).hasMatch(input);

      if (!validEmail) {
        return 'Enter a valid email address';
      }

      return null;
    }

    final String phone =
    _normalizePhone(input);

    if (!RegExp(
      r'^[6-9]\d{9}$',
    ).hasMatch(phone)) {
      return 'Enter a valid 10-digit mobile number';
    }

    return null;
  }

  Future<String> _resolveEmail(
      String identifier,
      ) async {
    final String input =
    identifier.trim();

    if (input.contains('@')) {
      return input.toLowerCase();
    }

    final String phone =
    _normalizePhone(input);

    QuerySnapshot<Map<String, dynamic>>
    result =
    await FirebaseFirestore.instance
        .collection('users')
        .where(
      'phoneNumber',
      isEqualTo: '+91$phone',
    )
        .limit(1)
        .get();

    if (result.docs.isEmpty) {
      result =
      await FirebaseFirestore.instance
          .collection('users')
          .where(
        'phoneNumber',
        isEqualTo: phone,
      )
          .limit(1)
          .get();
    }

    if (result.docs.isEmpty) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message:
        'No account was found for this mobile number.',
      );
    }

    final String email =
    (result.docs.first
        .data()['email'] ??
        '')
        .toString()
        .trim();

    if (email.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-email',
        message:
        'This mobile number is not linked to an email account.',
      );
    }

    return email.toLowerCase();
  }

  Future<void> _sendResetLink() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState
        ?.validate() ??
        false)) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final String email =
      await _resolveEmail(
        _identifierController.text,
      );

      await FirebaseAuth.instance
          .sendPasswordResetEmail(
        email: email,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _resolvedEmail = email;
        _emailSent = true;
      });
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      _showMessage(
        _firebaseMessage(error),
        isError: true,
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;

      _showMessage(
        error.message ??
            'Unable to process your request right now.',
        isError: true,
      );
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        'Unable to send reset link. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  String _firebaseMessage(
      FirebaseAuthException error,
      ) {
    switch (error.code) {
      case 'user-not-found':
        return error.message ??
            'No account was found with these details.';

      case 'invalid-email':
        return 'Enter a valid email address.';

      case 'missing-email':
        return error.message ??
            'This account has no email linked to it.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'network-request-failed':
        return 'Check your internet connection and try again.';

      default:
        return error.message ??
            'Unable to send password reset link.';
    }
  }

  String _maskEmail(
      String email,
      ) {
    final List<String> parts =
    email.split('@');

    if (parts.length != 2 ||
        parts.first.isEmpty) {
      return email;
    }

    final String name =
        parts.first;

    final String domain =
        parts.last;

    if (name.length <= 2) {
      return '${name.substring(0, 1)}***@$domain';
    }

    return '${name.substring(0, 2)}***@$domain';
  }

  void _showMessage(
      String message, {
        required bool isError,
      }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior:
          SnackBarBehavior.floating,
          backgroundColor:
          isError
              ? AppColors.error
              : AppColors.primary,
          margin:
          const EdgeInsets.all(16),
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(16),
          ),
          content: Row(
            children: <Widget>[
              Icon(
                isError
                    ? Icons
                    .error_outline_rounded
                    : Icons
                    .check_circle_outline_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style:
                  const TextStyle(
                    color: Colors.white,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  void _goToLogin() {
    if (Navigator.of(context)
        .canPop()) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context)
        .pushReplacementNamed(
      AppRoutes.login,
    );
  }

  void _useAnotherAccount() {
    setState(() {
      _emailSent = false;
      _resolvedEmail = '';
      _identifierController.clear();
    });

    WidgetsBinding.instance
        .addPostFrameCallback(
          (_) {
        if (mounted) {
          _identifierFocusNode
              .requestFocus();
        }
      },
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final double width =
        MediaQuery.sizeOf(context)
            .width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor:
      AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const _ForgotPasswordBackground(),

          SafeArea(
            child:
            SingleChildScrollView(
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior
                  .onDrag,
              padding:
              EdgeInsets.symmetric(
                horizontal:
                width >= 700
                    ? 28
                    : 18,
                vertical: 20,
              ),
              child: Center(
                child:
                ConstrainedBox(
                  constraints:
                  const BoxConstraints(
                    maxWidth: 560,
                  ),
                  child:
                  FadeTransition(
                    opacity:
                    _fadeAnimation,
                    child:
                    SlideTransition(
                      position:
                      _slideAnimation,
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .stretch,
                        children:
                        <Widget>[
                          _buildTopBar(),

                          const SizedBox(
                            height: 32,
                          ),

                          _emailSent
                              ? _buildSuccessCard()
                              : _buildResetCard(),
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
          borderRadius:
          BorderRadius.circular(16),
          child: InkWell(
            borderRadius:
            BorderRadius.circular(16),
            onTap:
            _loading
                ? null
                : _goToLogin,
            child:
            const SizedBox(
              width: 46,
              height: 46,
              child: Icon(
                Icons
                    .arrow_back_ios_new_rounded,
                size: 18,
              ),
            ),
          ),
        ),

        const SizedBox(width: 14),

        const Text(
          'Forgot Password',
          style: TextStyle(
            color:
            AppColors.primaryDark,
            fontSize: 18,
            fontWeight:
            FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildResetCard() {
    return ClipRRect(
      borderRadius:
      BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Container(
          padding:
          const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white
                .withValues(
              alpha: 0.96,
            ),
            borderRadius:
            BorderRadius.circular(
              30,
            ),
            border: Border.all(
              color: Colors.white
                  .withValues(
                alpha: 0.72,
              ),
            ),
            boxShadow:
            const <BoxShadow>[
              BoxShadow(
                color:
                Color(0x16000000),
                blurRadius: 40,
                offset:
                Offset(0, 18),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .stretch,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 92,
                      height: 92,
                      decoration:
                      BoxDecoration(
                        gradient:
                        const LinearGradient(
                          colors:
                          <Color>[
                            Color(
                              0xFF0B7A3E,
                            ),
                            Color(
                              0xFF23A559,
                            ),
                          ],
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(
                          28,
                        ),
                        boxShadow:
                        const <BoxShadow>[
                          BoxShadow(
                            color:
                            Color(
                              0x300B7A3E,
                            ),
                            blurRadius:
                            26,
                            offset:
                            Offset(
                              0,
                              13,
                            ),
                          ),
                        ],
                      ),
                      child:
                      const Icon(
                        Icons
                            .lock_reset_rounded,
                        color:
                        Colors.white,
                        size: 46,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  const Text(
                    'Reset your password',
                    textAlign:
                    TextAlign.center,
                    style: TextStyle(
                      color: AppColors
                          .textPrimary,
                      fontSize: 27,
                      fontWeight:
                      FontWeight.w900,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  const Text(
                    'Enter your registered email or mobile number. We will send a secure password reset link to your email.',
                    textAlign:
                    TextAlign.center,
                    style: TextStyle(
                      color: AppColors
                          .textSecondary,
                      fontSize: 13.5,
                      height: 1.45,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  TextFormField(
                    controller:
                    _identifierController,
                    focusNode:
                    _identifierFocusNode,
                    enabled: !_loading,
                    keyboardType:
                    TextInputType
                        .emailAddress,
                    textInputAction:
                    TextInputAction.done,
                    autofillHints:
                    const <String>[
                      AutofillHints
                          .username,
                      AutofillHints.email,
                      AutofillHints
                          .telephoneNumber,
                    ],
                    validator:
                    _validateIdentifier,
                    onFieldSubmitted:
                        (_) {
                      if (!_loading) {
                        _sendResetLink();
                      }
                    },
                    decoration:
                    const InputDecoration(
                      labelText:
                      'Email or phone number',
                      hintText:
                      'name@example.com or 98765 43210',
                      prefixIcon:
                      Icon(
                        Icons
                            .person_search_outlined,
                        color:
                        AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  SizedBox(
                    height: 56,
                    child:
                    FilledButton(
                      onPressed:
                      _loading
                          ? null
                          : _sendResetLink,
                      child:
                      _loading
                          ? const SizedBox(
                        width:
                        23,
                        height:
                        23,
                        child:
                        CircularProgressIndicator(
                          color:
                          Colors.white,
                          strokeWidth:
                          2.5,
                        ),
                      )
                          : const Text(
                        'SEND RESET LINK',
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  TextButton.icon(
                    onPressed:
                    _loading
                        ? null
                        : _goToLogin,
                    icon: const Icon(
                      Icons.login_rounded,
                      size: 19,
                    ),
                    label: const Text(
                      'Back to Login',
                      style: TextStyle(
                        fontWeight:
                        FontWeight
                            .w900,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Container(
                    padding:
                    const EdgeInsets
                        .all(14),
                    decoration:
                    BoxDecoration(
                      color:
                      const Color(
                        0xFFF1F8F4,
                      ),
                      borderRadius:
                      BorderRadius
                          .circular(16),
                      border:
                      Border.all(
                        color:
                        const Color(
                          0xFFDCEFE4,
                        ),
                      ),
                    ),
                    child:
                    const Row(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children:
                      <Widget>[
                        Icon(
                          Icons
                              .shield_outlined,
                          color:
                          AppColors
                              .primary,
                          size: 20,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            'For security, the reset link is sent only to the email linked with your Farm To Home account.',
                            style:
                            TextStyle(
                              color:
                              AppColors
                                  .textSecondary,
                              fontSize:
                              11.5,
                              height:
                              1.45,
                              fontWeight:
                              FontWeight
                                  .w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessCard() {
    return Container(
      padding:
      const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(30),
        boxShadow:
        const <BoxShadow>[
          BoxShadow(
            color:
            Color(0x16000000),
            blurRadius: 40,
            offset:
            Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              width: 94,
              height: 94,
              decoration:
              BoxDecoration(
                color:
                const Color(
                  0xFFEAF8EF,
                ),
                borderRadius:
                BorderRadius.circular(
                  30,
                ),
              ),
              child: const Icon(
                Icons
                    .mark_email_read_outlined,
                color:
                AppColors.primary,
                size: 48,
              ),
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          const Text(
            'Check your email',
            textAlign:
            TextAlign.center,
            style: TextStyle(
              color:
              AppColors.textPrimary,
              fontSize: 28,
              fontWeight:
              FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            'We sent a password reset link to\n${_maskEmail(_resolvedEmail)}',
            textAlign:
            TextAlign.center,
            style:
            const TextStyle(
              color:
              AppColors.textSecondary,
              fontSize: 13.5,
              height: 1.5,
              fontWeight:
              FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 26,
          ),

          SizedBox(
            height: 56,
            child: FilledButton(
              onPressed: _goToLogin,
              child: const Text(
                'BACK TO LOGIN',
              ),
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          TextButton(
            onPressed:
            _loading
                ? null
                : _sendResetLink,
            child: const Text(
              'Resend reset link',
              style: TextStyle(
                fontWeight:
                FontWeight.w900,
              ),
            ),
          ),

          TextButton(
            onPressed:
            _loading
                ? null
                : _useAnotherAccount,
            child: const Text(
              'Use another account',
              style: TextStyle(
                fontWeight:
                FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForgotPasswordBackground
    extends StatelessWidget {
  const _ForgotPasswordBackground();

  @override
  Widget build(
      BuildContext context,
      ) {
    return Stack(
      children: <Widget>[
        const Positioned.fill(
          child: DecoratedBox(
            decoration:
            BoxDecoration(
              gradient:
              LinearGradient(
                begin:
                Alignment.topLeft,
                end:
                Alignment.bottomRight,
                colors:
                <Color>[
                  Color(
                    0xFFE8F6ED,
                  ),
                  Color(
                    0xFFFFFBF2,
                  ),
                  AppColors
                      .background,
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
            decoration:
            const BoxDecoration(
              shape:
              BoxShape.circle,
              color:
              Color(
                0x100B7A3E,
              ),
            ),
          ),
        ),

        Positioned(
          bottom: -120,
          left: -100,
          child: Container(
            width: 320,
            height: 320,
            decoration:
            const BoxDecoration(
              shape:
              BoxShape.circle,
              color:
              Color(
                0x10F4B400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}