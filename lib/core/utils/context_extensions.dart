import 'package:flutter/material.dart';
import 'package:melocue/core/theme/app_colors.dart';
import 'package:melocue/l10n/app_localizations.dart';

extension BuildContextExtensions on BuildContext {
  // Theme Extensions
  ThemeData get theme => Theme.of(this);
  TextTheme get typography => theme.textTheme;
  ColorScheme get colors => theme.colorScheme;
  
  // Custom App Colors (if direct access is needed)
  Color get surfaceContainerLowest => AppColors.surfaceContainerLowest;
  Color get surfaceContainerLow => AppColors.surfaceContainerLow;
  Color get surfaceContainer => AppColors.surfaceContainer;
  Color get surfaceContainerHigh => AppColors.surfaceContainerHigh;
  Color get surfaceContainerHighest => AppColors.surfaceContainerHighest;
  Color get surfaceVariant => AppColors.surfaceVariant;
  Color get onSurfaceVariant => AppColors.onSurfaceVariant;
  Color get primaryFixed => AppColors.primaryFixed;
  Color get primaryFixedDim => AppColors.primaryFixedDim;
  Color get secondaryFixed => AppColors.secondaryFixed;
  Color get secondaryFixedDim => AppColors.secondaryFixedDim;
  Color get tertiaryFixed => AppColors.tertiaryFixed;
  Color get tertiaryFixedDim => AppColors.tertiaryFixedDim;

  // Sizing Extensions
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  // Relative sizing helpers (e.g. context.w(0.5) = 50% of screen width)
  double w(double percentage) => screenWidth * percentage;
  double h(double percentage) => screenHeight * percentage;
  
  // Padding & Spacing
  EdgeInsets get viewInsets => mediaQuery.viewInsets;
  EdgeInsets get viewPadding => mediaQuery.viewPadding;

  // Localization
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

// Spacing extensions on num
extension NumSpacingExtensions on num {
  SizedBox get h => SizedBox(height: toDouble());
  SizedBox get w => SizedBox(width: toDouble());
}
