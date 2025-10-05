import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

import '../../../core/theme/app_theme.dart';

/// Custom button widget with beautiful animations and gradients
class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final CustomButtonType type;
  final CustomButtonSize size;
  final Widget? icon;
  final String? lottieAsset;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.type = CustomButtonType.primary,
    this.size = CustomButtonSize.large,
    this.icon,
    this.lottieAsset,
    this.width,
    this.padding,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.isEnabled && !widget.isLoading) {
      setState(() {
        _isPressed = true;
      });
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _handleTapEnd();
  }

  void _handleTapCancel() {
    _handleTapEnd();
  }

  void _handleTapEnd() {
    if (_isPressed) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.isEnabled && !widget.isLoading ? widget.onPressed : null,
            child: Container(
              width: widget.width ?? _getButtonWidth(),
              height: _getButtonHeight(),
              decoration: BoxDecoration(
                gradient: _getGradient(theme, isDark),
                color: _getBackgroundColor(theme),
                borderRadius: BorderRadius.circular(_getBorderRadius()),
                boxShadow: _getBoxShadow(theme, isDark),
                border: _getBorder(theme),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(_getBorderRadius()),
                  onTap: widget.isEnabled && !widget.isLoading ? widget.onPressed : null,
                  child: Container(
                    padding: widget.padding ?? _getPadding(),
                    child: _buildButtonContent(theme),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildButtonContent(ThemeData theme) {
    if (widget.isLoading) {
      return _buildLoadingContent(theme);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          widget.icon!,
          const SizedBox(width: 8),
        ],
        if (widget.lottieAsset != null) ...[
          SizedBox(
            width: 24,
            height: 24,
            child: Lottie.asset(
              widget.lottieAsset!,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.text,
            style: _getTextStyle(theme),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingContent(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getTextColor(theme),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Loading...',
          style: _getTextStyle(theme),
        ),
      ],
    );
  }

  Gradient? _getGradient(ThemeData theme, bool isDark) {
    switch (widget.type) {
      case CustomButtonType.primary:
        return isDark ? AppTheme.darkBackgroundGradient : AppTheme.primaryGradient;
      case CustomButtonType.secondary:
        return isDark ? AppTheme.darkCardGradient : AppTheme.cardGradient;
      case CustomButtonType.outline:
        return null;
      case CustomButtonType.text:
        return null;
      case CustomButtonType.white:
        return null;
    }
  }

  Color? _getBackgroundColor(ThemeData theme) {
    switch (widget.type) {
      case CustomButtonType.white:
        return Colors.white;
      default:
        return null;
    }
  }

  List<BoxShadow> _getBoxShadow(ThemeData theme, bool isDark) {
    if (widget.type == CustomButtonType.text) return [];
    
    return [
      BoxShadow(
        color: theme.colorScheme.primary.withOpacity(0.3),
        blurRadius: _isPressed ? 4 : 8,
        offset: Offset(0, _isPressed ? 2 : 4),
      ),
    ];
  }

  Border? _getBorder(ThemeData theme) {
    if (widget.type == CustomButtonType.outline) {
      return Border.all(
        color: theme.colorScheme.primary,
        width: 2,
      );
    }
    return null;
  }


  Color _getTextColor(ThemeData theme) {
    switch (widget.type) {
      case CustomButtonType.primary:
        return Colors.white;
      case CustomButtonType.secondary:
        return theme.colorScheme.onSecondary;
      case CustomButtonType.outline:
        return theme.colorScheme.primary;
      case CustomButtonType.text:
        return theme.colorScheme.primary;
      case CustomButtonType.white:
        return Colors.black;
    }
  }

  TextStyle _getTextStyle(ThemeData theme) {
    return TextStyle(
      fontSize: _getFontSize(),
      fontWeight: FontWeight.w600,
      color: _getTextColor(theme),
      fontFamily: 'Inter',
    );
  }

  double _getButtonWidth() {
    switch (widget.size) {
      case CustomButtonSize.small:
        return 100;
      case CustomButtonSize.medium:
        return 140;
      case CustomButtonSize.large:
        return 200;
    }
  }

  double _getButtonHeight() {
    switch (widget.size) {
      case CustomButtonSize.small:
        return 36;
      case CustomButtonSize.medium:
        return 42;
      case CustomButtonSize.large:
        return 48;
    }
  }

  double _getBorderRadius() {
    switch (widget.size) {
      case CustomButtonSize.small:
        return 8;
      case CustomButtonSize.medium:
        return 12;
      case CustomButtonSize.large:
        return 16;
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (widget.size) {
      case CustomButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case CustomButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case CustomButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 10);
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case CustomButtonSize.small:
        return 12;
      case CustomButtonSize.medium:
        return 14;
      case CustomButtonSize.large:
        return 16;
    }
  }
}

/// Button type enum
enum CustomButtonType {
  primary,
  secondary,
  outline,
  text,
  white,
}

/// Button size enum
enum CustomButtonSize {
  small,
  medium,
  large,
}

/// Google sign-in button widget
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;

  const GoogleSignInButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: 'Google',
      onPressed: onPressed,
      isLoading: isLoading,
      isEnabled: isEnabled,
      type: CustomButtonType.outline,
      size: CustomButtonSize.medium,
      icon: Image.asset(
        'assets/icons/google_logo.png',
        width: 16,
        height: 16,
        fit: BoxFit.contain,
      ),
    );
  }
}


/// Social media button widget
class SocialButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;

  const SocialButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isEnabled: isEnabled,
      type: CustomButtonType.outline,
      size: CustomButtonSize.large,
      icon: Icon(
        icon,
        size: 20,
        color: iconColor ?? theme.colorScheme.primary,
      ),
    );
  }
}
