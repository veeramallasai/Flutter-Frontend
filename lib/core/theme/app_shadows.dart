import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();
  static const List<BoxShadow> soft = <BoxShadow>[
    BoxShadow(color: Color(0x0D000000), blurRadius: 18, offset: Offset(0, 8)),
  ];
  static const List<BoxShadow> elevated = <BoxShadow>[
    BoxShadow(color: Color(0x190B7A3E), blurRadius: 28, offset: Offset(0, 13)),
  ];
}
