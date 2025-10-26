import 'package:flutter/material.dart';

enum ModernButtonType {
  primary,
  secondary,
  outline,
  ghost,
  destructive,
}

enum ModernButtonSize {
  small,
  medium,
  large,
}

class ModernButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ModernButtonType type;
  final ModernButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final Color? customColor;

  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ModernButtonType.primary,
    this.size = ModernButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.customColor,
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
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
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _resetAnimation();
  }

  void _handleTapCancel() {
    _resetAnimation();
  }

  void _resetAnimation() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: isEnabled ? widget.onPressed : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.fullWidth ? double.infinity : null,
              padding: _getPadding(),
              decoration: _getDecoration(theme, isEnabled),
              child: Row(
                mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading) ...[
                    SizedBox(
                      width: _getIconSize(),
                      height: _getIconSize(),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getContentColor(theme, isEnabled),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ] else if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: _getIconSize(),
                      color: _getContentColor(theme, isEnabled),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: _getTextStyle(theme, isEnabled),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case ModernButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ModernButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case ModernButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ModernButtonSize.small:
        return 16;
      case ModernButtonSize.medium:
        return 18;
      case ModernButtonSize.large:
        return 20;
    }
  }

  BoxDecoration _getDecoration(ThemeData theme, bool isEnabled) {
    final baseColor = widget.customColor ?? theme.colorScheme.primary;
    
    switch (widget.type) {
      case ModernButtonType.primary:
        return BoxDecoration(
          color: isEnabled ? baseColor : baseColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          boxShadow: isEnabled && !_isPressed ? [
            BoxShadow(
              color: baseColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : null,
        );
      
      case ModernButtonType.secondary:
        return BoxDecoration(
          color: isEnabled 
              ? baseColor.withValues(alpha: 0.1) 
              : baseColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          border: Border.all(
            color: isEnabled 
                ? baseColor.withValues(alpha: 0.2) 
                : baseColor.withValues(alpha: 0.1),
          ),
        );
      
      case ModernButtonType.outline:
        return BoxDecoration(
          color: _isPressed && isEnabled 
              ? baseColor.withValues(alpha: 0.05) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          border: Border.all(
            color: isEnabled ? baseColor : baseColor.withValues(alpha: 0.5),
            width: 1.5,
          ),
        );
      
      case ModernButtonType.ghost:
        return BoxDecoration(
          color: _isPressed && isEnabled 
              ? baseColor.withValues(alpha: 0.1) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
        );
      
      case ModernButtonType.destructive:
        final destructiveColor = Colors.red;
        return BoxDecoration(
          color: isEnabled ? destructiveColor : destructiveColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          boxShadow: isEnabled && !_isPressed ? [
            BoxShadow(
              color: destructiveColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : null,
        );
    }
  }

  double _getBorderRadius() {
    switch (widget.size) {
      case ModernButtonSize.small:
        return 12;
      case ModernButtonSize.medium:
        return 14;
      case ModernButtonSize.large:
        return 16;
    }
  }

  Color _getContentColor(ThemeData theme, bool isEnabled) {
    final baseColor = widget.customColor ?? theme.colorScheme.primary;
    
    switch (widget.type) {
      case ModernButtonType.primary:
        return Colors.white;
      
      case ModernButtonType.secondary:
      case ModernButtonType.outline:
      case ModernButtonType.ghost:
        return isEnabled ? baseColor : baseColor.withValues(alpha: 0.5);
      
      case ModernButtonType.destructive:
        return Colors.white;
    }
  }

  TextStyle _getTextStyle(ThemeData theme, bool isEnabled) {
    final baseStyle = switch (widget.size) {
      ModernButtonSize.small => theme.textTheme.labelMedium,
      ModernButtonSize.medium => theme.textTheme.labelLarge,
      ModernButtonSize.large => theme.textTheme.titleMedium,
    };

    return baseStyle?.copyWith(
      fontWeight: FontWeight.w600,
      color: _getContentColor(theme, isEnabled),
    ) ?? TextStyle(
      fontWeight: FontWeight.w600,
      color: _getContentColor(theme, isEnabled),
    );
  }
}
