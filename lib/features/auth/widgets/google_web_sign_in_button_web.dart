import 'package:flutter/widgets.dart';
import 'package:google_sign_in_web/web_only.dart';

Widget buildGoogleWebSignInButton() => Builder(
  builder: (BuildContext context) {
    final double width = (MediaQuery.sizeOf(context).width - 96).clamp(1, 310);

    return Center(
      child: SizedBox(
        width: width,
        child: renderButton(
          configuration: GSIButtonConfiguration(
            type: GSIButtonType.standard,
            theme: GSIButtonTheme.outline,
            size: GSIButtonSize.large,
            text: GSIButtonText.continueWith,
            shape: GSIButtonShape.pill,
            logoAlignment: GSIButtonLogoAlignment.left,
            minimumWidth: width,
          ),
        ),
      ),
    );
  },
);
