import 'package:flutter/widgets.dart';
import 'package:google_sign_in_web/web_only.dart';

Widget buildGoogleWebSignInButton() => Center(
  child: renderButton(
    configuration: GSIButtonConfiguration(
      type: GSIButtonType.standard,
      theme: GSIButtonTheme.outline,
      size: GSIButtonSize.large,
      text: GSIButtonText.continueWith,
      shape: GSIButtonShape.rectangular,
      logoAlignment: GSIButtonLogoAlignment.left,
      minimumWidth: 320,
    ),
  ),
);
