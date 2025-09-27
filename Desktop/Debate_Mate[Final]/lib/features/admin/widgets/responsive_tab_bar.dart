import 'package:flutter/material.dart';
import 'responsive_layout.dart';

/// A responsive tab bar widget that prevents overflow on mobile devices
class ResponsiveTabBar extends StatelessWidget {
  final TabController controller;
  final List<TabData> tabs;
  final EdgeInsetsGeometry? margin;
  final BoxDecoration? decoration;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final Decoration? indicator;
  final TabBarIndicatorSize? indicatorSize;
  final bool isScrollable;

  const ResponsiveTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.margin,
    this.decoration,
    this.labelColor,
    this.unselectedLabelColor,
    this.indicator,
    this.indicatorSize = TabBarIndicatorSize.tab,
    this.isScrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: margin ?? ResponsiveLayout.getTabMargin(context),
      decoration: decoration ?? BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: controller,
        isScrollable: isScrollable,
        tabAlignment: TabAlignment.center,
        indicator: indicator ?? BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.primary,
        ),
        indicatorSize: indicatorSize,
        labelColor: labelColor ?? Colors.white,
        unselectedLabelColor: unselectedLabelColor ?? theme.colorScheme.onSurfaceVariant,
        labelStyle: TextStyle(
          fontSize: ResponsiveLayout.getFontSize(context),
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: ResponsiveLayout.getFontSize(context),
          fontWeight: FontWeight.w400,
        ),
        tabs: tabs.map((tabData) => _buildResponsiveTab(context, tabData)).toList(),
      ),
    );
  }

  Widget _buildResponsiveTab(BuildContext context, TabData tabData) {
    return Tab(
      height: ResponsiveLayout.getTabHeight(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (tabData.icon != null) ...[
            Icon(tabData.icon, size: ResponsiveLayout.getIconSize(context)),
            SizedBox(width: ResponsiveLayout.isMobile(context) ? 4 : 6),
          ],
          Flexible(
            child: Text(
              tabData.text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ResponsiveLayout.getFontSize(context, isSmall: true),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Data class for tab information
class TabData {
  final String text;
  final IconData? icon;
  final Widget? customChild;

  const TabData({
    required this.text,
    this.icon,
    this.customChild,
  });

  /// Create a tab with icon and text
  const TabData.withIcon({
    required this.text,
    required this.icon,
  }) : customChild = null;

  /// Create a tab with custom child widget
  const TabData.custom({
    required this.text,
    required this.customChild,
  }) : icon = null;
}

/// A compact tab bar for mobile devices with shorter labels
class CompactTabBar extends StatelessWidget {
  final TabController controller;
  final List<CompactTabData> tabs;
  final EdgeInsetsGeometry? margin;

  const CompactTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: margin ?? ResponsiveLayout.getTabMargin(context),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.center,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.primary,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        labelStyle: TextStyle(
          fontSize: ResponsiveLayout.getFontSize(context, isSmall: true),
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: ResponsiveLayout.getFontSize(context, isSmall: true),
          fontWeight: FontWeight.w400,
        ),
        tabs: tabs.map((tabData) => _buildCompactTab(context, tabData)).toList(),
      ),
    );
  }

  Widget _buildCompactTab(BuildContext context, CompactTabData tabData) {
    return Tab(
      height: ResponsiveLayout.getTabHeight(context) - 8, // Slightly smaller
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(tabData.icon, size: ResponsiveLayout.getIconSize(context) - 2),
          const SizedBox(height: 2),
          Text(
            tabData.shortText,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: ResponsiveLayout.getFontSize(context, isSmall: true) - 2,
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

/// Data class for compact tab information
class CompactTabData {
  final String text;
  final String shortText;
  final IconData icon;

  const CompactTabData({
    required this.text,
    required this.shortText,
    required this.icon,
  });
}
