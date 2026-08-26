import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Farm To Home typography system.
/// Manrope: titles/prices/primary CTA headings.
/// DM Sans: body, forms, buttons, navigation, badges.
abstract final class AppTypography {
  static TextStyle pageTitle({Color? color}) => GoogleFonts.manrope(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: color,
  );

  static TextStyle priceLarge({Color? color}) => GoogleFonts.manrope(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: color,
  );

  static TextStyle screenTitle({Color? color}) => GoogleFonts.manrope(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.5,
    color: color,
  );

  static TextStyle sectionTitle({Color? color}) => GoogleFonts.manrope(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: color,
  );

  static TextStyle cardTitle({Color? color}) => GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: color,
  );

  static TextStyle subtitle({Color? color}) => GoogleFonts.manrope(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: color,
  );

  static TextStyle priceSmall({Color? color}) => GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: color,
  );

  static TextStyle cardName({Color? color}) => GoogleFonts.manrope(
    fontSize: 13,
    fontWeight: FontWeight.w800,
    color: color,
  );

  static TextStyle ctaLarge({Color? color}) => GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: color,
  );

  static TextStyle ctaMedium({Color? color}) => GoogleFonts.manrope(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: color,
  );

  static TextStyle weightOption({Color? color}) => GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: color,
  );

  static TextStyle tagUpper({Color? color}) => GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.2,
    color: color,
  );

  static TextStyle badge({Color? color}) => GoogleFonts.dmSans(
    fontSize: 10,
    fontWeight: FontWeight.w800,
    letterSpacing: 1,
    color: color,
  );

  static TextStyle buttonPrimary({Color? color}) => GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: color,
  );

  static TextStyle buttonSocial({Color? color}) => GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: color,
  );

  static TextStyle filterLabel({Color? color}) => GoogleFonts.dmSans(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: color,
  );

  static TextStyle buttonCard({Color? color}) => GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: color,
  );

  static TextStyle navActive({Color? color}) => GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: color,
  );

  static TextStyle microBold({Color? color}) => GoogleFonts.dmSans(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: color,
  );

  static TextStyle badgeSmall({Color? color}) => GoogleFonts.dmSans(
    fontSize: 9,
    fontWeight: FontWeight.w700,
    color: color,
  );

  static TextStyle statusBar({Color? color}) => GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle inputLabel({Color? color}) => GoogleFonts.dmSans(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle chip({Color? color}) => GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle overline({Color? color}) => GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1,
    color: color,
  );

  static TextStyle navInactive({Color? color}) => GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: color,
  );

  static TextStyle inputText({Color? color}) => GoogleFonts.dmSans(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: color,
  );

  static TextStyle body({Color? color}) => GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: color,
  );

  static TextStyle bodySmall({Color? color}) => GoogleFonts.dmSans(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: color,
  );

  static TextStyle bodyXs({Color? color}) => GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: color,
  );

  static TextStyle caption({Color? color}) => GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: color,
  );

  static TextStyle micro({Color? color}) => GoogleFonts.dmSans(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: color,
  );
}
