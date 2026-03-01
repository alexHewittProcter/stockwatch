import 'package:flutter/material.dart';

class AppColors {
  // Dark Bloomberg-terminal style colors
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color surfaceVariant = Color(0xFF21262D);
  static const Color border = Color(0xFF30363D);
  static const Color borderSubtle = Color(0xFF21262D);
  
  // Text colors
  static const Color textPrimary = Color(0xFFF0F6FC);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textMuted = Color(0xFF6E7681);
  
  // Accent colors
  static const Color positive = Color(0xFF238636);
  static const Color positiveText = Color(0xFF3FB950);
  static const Color negative = Color(0xFFDA3633);
  static const Color negativeText = Color(0xFFF85149);
  static const Color warning = Color(0xFFD29922);
  static const Color warningText = Color(0xFFE3B341);
  static const Color info = Color(0xFF1F6FEB);
  static const Color infoText = Color(0xFF58A6FF);
  
  // Chart colors
  static const Color chartGrid = Color(0xFF30363D);
  static const Color chartCandleUp = Color(0xFF238636);
  static const Color chartCandleDown = Color(0xFFDA3633);
  static const Color chartVolume = Color(0xFF8B949E);
  static const Color chartCrosshair = Color(0xFF58A6FF);
  
  // Special colors
  static const Color selection = Color(0xFF1F6FEB);
  static const Color selectionBackground = Color(0xFF0969DA);
  static const Color hover = Color(0xFF21262D);
}

class AppTextStyles {
  static const String fontFamily = 'SF Mono';
  
  // Numbers should be monospace for alignment
  static const TextStyle numberLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle numberMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle numberSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
  
  // Regular text styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );
  
  // Specialized styles
  static const TextStyle ticker = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      
      // Color scheme
      colorScheme: const ColorScheme.dark(
        background: AppColors.background,
        surface: AppColors.surface,
        surfaceVariant: AppColors.surfaceVariant,
        onBackground: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        primary: AppColors.info,
        onPrimary: Colors.white,
        secondary: AppColors.textSecondary,
        onSecondary: Colors.white,
        outline: AppColors.border,
        outlineVariant: AppColors.borderSubtle,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: AppColors.background,
      
      // App bar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        titleTextStyle: AppTextStyles.headingMedium,
        iconTheme: IconThemeData(color: AppColors.textSecondary),
      ),
      
      // Cards
      cardTheme: CardTheme(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      
      // Dividers
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.info,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          textStyle: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          hoverColor: AppColors.hover,
        ),
      ),
      
      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.info, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      ),
      
      // Lists
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: AppColors.selectionBackground,
        textColor: AppColors.textPrimary,
        iconColor: AppColors.textSecondary,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      
      // Data tables
      dataTableTheme: DataTableThemeData(
        headingRowColor: MaterialStateProperty.all(AppColors.surfaceVariant),
        dataRowColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.selectionBackground;
          }
          return AppColors.surface;
        }),
        headingTextStyle: AppTextStyles.label.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        dataTextStyle: AppTextStyles.bodyMedium,
        dividerThickness: 1,
        horizontalMargin: 16,
        columnSpacing: 24,
      ),
      
      // Tab bar
      tabBarTheme: const TabBarTheme(
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.info,
        labelStyle: AppTextStyles.bodyMedium,
        unselectedLabelStyle: AppTextStyles.bodyMedium,
      ),
      
      // Tooltips
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.border),
        ),
        textStyle: AppTextStyles.bodySmall,
      ),
      
      // Dialogs
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.headingMedium,
        contentTextStyle: AppTextStyles.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      
      // Bottom sheets
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          side: BorderSide(color: AppColors.border),
        ),
      ),
      
      // Navigation rail
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.surface,
        selectedIconTheme: const IconThemeData(color: AppColors.info),
        unselectedIconTheme: const IconThemeData(color: AppColors.textMuted),
        selectedLabelTextStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.info),
        unselectedLabelTextStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
        useIndicator: true,
        indicatorColor: AppColors.selectionBackground,
      ),
      
      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.info;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        side: const BorderSide(color: AppColors.border, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),
      
      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.white;
          }
          return AppColors.textMuted;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.info;
          }
          return AppColors.borderSubtle;
        }),
      ),
      
      // Text theme
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.headingLarge,
        displayMedium: AppTextStyles.headingMedium,
        displaySmall: AppTextStyles.headingSmall,
        headlineLarge: AppTextStyles.headingLarge,
        headlineMedium: AppTextStyles.headingMedium,
        headlineSmall: AppTextStyles.headingSmall,
        titleLarge: AppTextStyles.headingMedium,
        titleMedium: AppTextStyles.headingSmall,
        titleSmall: AppTextStyles.label,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.label,
        labelMedium: AppTextStyles.caption,
        labelSmall: AppTextStyles.caption,
      ),
    );
  }
}

// Utility extensions for colors based on values
extension ColorUtils on Color {
  /// Returns appropriate text color for this background
  Color get onColor {
    return computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}

extension NumberColors on num {
  /// Returns appropriate color for a change value (positive/negative)
  Color get changeColor {
    if (this > 0) return AppColors.positiveText;
    if (this < 0) return AppColors.negativeText;
    return AppColors.textSecondary;
  }
  
  /// Returns appropriate color with background for a change value
  Color get changeBackgroundColor {
    if (this > 0) return AppColors.positive.withOpacity(0.1);
    if (this < 0) return AppColors.negative.withOpacity(0.1);
    return Colors.transparent;
  }
}

extension TextStyleUtils on TextStyle {
  /// Apply change color based on numeric value
  TextStyle withChangeColor(num value) {
    return copyWith(color: value.changeColor);
  }
  
  /// Apply positive color
  TextStyle get positive => copyWith(color: AppColors.positiveText);
  
  /// Apply negative color
  TextStyle get negative => copyWith(color: AppColors.negativeText);
  
  /// Apply muted color
  TextStyle get muted => copyWith(color: AppColors.textMuted);
  
  /// Apply secondary color
  TextStyle get secondary => copyWith(color: AppColors.textSecondary);
}