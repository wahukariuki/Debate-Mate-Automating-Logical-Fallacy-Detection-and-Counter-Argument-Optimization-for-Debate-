import 'package:flutter/material.dart';

/// Responsive layout utilities for admin screens
class ResponsiveLayout {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1024;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  static int getGridCrossAxisCount(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 3;
  }

  static double getCardAspectRatio(BuildContext context) {
    if (isMobile(context)) return 1.5;
    if (isTablet(context)) return 1.3;
    return 1.2;
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(20);
    } else {
      return const EdgeInsets.all(24);
    }
  }

  static EdgeInsets getTabMargin(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 12);
    } else {
      return const EdgeInsets.symmetric(horizontal: 16);
    }
  }

  static double getTabHeight(BuildContext context) {
    if (isMobile(context)) {
      return 48.0;
    } else {
      return 56.0;
    }
  }

  static double getIconSize(BuildContext context) {
    if (isMobile(context)) {
      return 16.0;
    } else {
      return 18.0;
    }
  }

  static double getFontSize(BuildContext context, {bool isSmall = false}) {
    if (isMobile(context)) {
      return isSmall ? 10.0 : 12.0;
    } else {
      return isSmall ? 12.0 : 14.0;
    }
  }
}

/// A responsive container that adapts to screen size
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxDecoration? decoration;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? ResponsiveLayout.getScreenPadding(context),
      margin: margin,
      decoration: decoration,
      child: child,
    );
  }
}

/// A responsive grid that adapts to screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double? childAspectRatio;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.childAspectRatio,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: ResponsiveLayout.getGridCrossAxisCount(context),
      childAspectRatio: childAspectRatio ?? ResponsiveLayout.getCardAspectRatio(context),
      crossAxisSpacing: crossAxisSpacing ?? 16,
      mainAxisSpacing: mainAxisSpacing ?? 16,
      children: children,
    );
  }
}

/// A responsive row that stacks on mobile
class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double? spacing;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveLayout.isMobile(context)) {
      // Stack vertically on mobile
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children
            .expand((widget) => [
                  widget,
                  if (widget != children.last)
                    SizedBox(height: spacing ?? 16),
                ])
            .toList(),
      );
    } else {
      // Display horizontally on larger screens
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children
            .expand((widget) => [
                  widget,
                  if (widget != children.last)
                    SizedBox(width: spacing ?? 16),
                ])
            .toList(),
      );
    }
  }
}

/// A responsive text widget that adjusts size based on screen
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool isSmall;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style?.copyWith(
            fontSize: ResponsiveLayout.getFontSize(context, isSmall: isSmall),
          ) ??
          TextStyle(
            fontSize: ResponsiveLayout.getFontSize(context, isSmall: isSmall),
          ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
