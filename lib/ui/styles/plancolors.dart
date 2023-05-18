import 'package:flutter/material.dart';

/// Class to contain style and color information
/// for a unified experience.
/// Currently supports only on mode. No day/night 
/// differences.
class PlanColors {
  static const _primaryTextColor = 0xFF172B4C;
  static const _secondaryTextColor = 0xFFA4AEBA;
  static const _selectedIconColor = _primaryTextColor;
  static const _iconColor = _secondaryTextColor;
  static const _borderColor = 0xFFE3E4E8;
  static const _tabBorderColor = 0xFFECEDF1;
  static const _unknownSchoolColor = 0xFFC91D1D;
  static const _planDayBackgroundColor = 0xFFF7F7F8;
  static const _pageIndicatorColor = 0xFFF4F4F6;
  static const _pageIndicatorSelectedColor = 0xFFA3ADBA;
  static const _planBackgroundColor = 0xFFA3ADBA;
  static const _appBackgroundColor = 0xFFFFFFFF;
  // ignore: constant_identifier_names
  static const Color LogoBackgroundColor = Color(0xFF006CA5);

  static final Map<int, Color> _matColors = {
      50: const Color(_primaryTextColor & 0x19FFFFFF),
      100: const Color(_primaryTextColor & 0x37FFFFFF),
      200: const Color(_primaryTextColor & 0x50FFFFFF),
      300: const Color(_primaryTextColor & 0x69FFFFFF),
      400: const Color(_primaryTextColor & 0x82FFFFFF),
      500: const Color(_primaryTextColor & 0x9BFFFFFF),
      600: const Color(_primaryTextColor & 0xB4FFFFFF),
      700: const Color(_primaryTextColor & 0xCDFFFFFF),
      800: const Color(_primaryTextColor & 0xE6FFFFFF),
      900: PrimaryTextColor
  };

  /// Converts a hex value to a list of int representative.
  /// E.g. #ffffff is converted to [255, 255, 255].
  static List<int> convertColor(String color) {
    return [
      int.parse(color.substring(1, 3), radix: 16),
      int.parse(color.substring(3, 5), radix: 16),
      int.parse(color.substring(5), radix: 16)
    ];
  }

  // ignore: non_constant_identifier_names
  static Color get PrimaryTextColor {
    return const Color(_primaryTextColor);
  }

  // ignore: non_constant_identifier_names
  static MaterialColor get MatPrimaryTextColor {
    return MaterialColor(_primaryTextColor, _matColors);
  }

  // ignore: non_constant_identifier_names
  static Color get SecondaryTextColor {
    return const Color(_secondaryTextColor);
  }

  // ignore: non_constant_identifier_names
  static Color get SelectedIconColor {
    return const Color(_selectedIconColor);
  }

  // ignore: non_constant_identifier_names
  static Color get IconColor {
    return const Color(_iconColor);
  }

  // ignore: non_constant_identifier_names
  static Color get BorderColor {
    return const Color(_borderColor);
  }

  // ignore: non_constant_identifier_names
  static Color get TabBorderColor {
    return const Color(_tabBorderColor);
  }

  // ignore: non_constant_identifier_names
  static Color get UnknownSchoolColor {
    return const Color(_unknownSchoolColor);
  }

  // ignore: non_constant_identifier_names
  static Color get PlanDayBackgroundColor {
    return const Color(_planDayBackgroundColor);
  }

  // ignore: non_constant_identifier_names
  static Color get PlanBackgroundColor {
    return const Color(_planBackgroundColor);
  }

  // ignore: non_constant_identifier_names
  static Color get PageIndicatorColor {
    return const Color(_pageIndicatorColor);
  }

  // ignore: non_constant_identifier_names
  static Color get PageIndicatorSelectedColor {
    return const Color(_pageIndicatorSelectedColor);
  }

  // ignore: non_constant_identifier_names
  static Color get AppBackgroundColor {
    return const Color(_appBackgroundColor);
  }
}