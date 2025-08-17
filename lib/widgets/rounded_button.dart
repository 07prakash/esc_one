import 'package:flutter/material.dart';
import '../utils/constants.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final IconData? icon;
  final bool isOutlined;
  final bool isSecondary;
  final bool isMotivational;
  final bool isPenalty;
  
  const RoundedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.icon,
    this.isOutlined = false,
    this.isSecondary = false,
    this.isMotivational = false,
    this.isPenalty = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 56,
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: isOutlined
            ? Border.all(
                color: AppConstants.softBlue,
                width: 2, // Increased border width for visibility
              )
            : null,
        boxShadow: AppConstants.mediumShadow, // More visible shadow
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3, // Increased stroke width
                      valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          size: 24, // Increased icon size
                          color: _getTextColor(),
                        ),
                        const SizedBox(width: AppConstants.smallPadding),
                      ],
                      Flexible(
                        child: Text(
                          text,
                          style: AppConstants.buttonStyle.copyWith(
                            color: _getTextColor(),
                            fontWeight: FontWeight.w700, // Increased weight
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (backgroundColor != null) return backgroundColor!;
    
    if (isOutlined) return Colors.transparent;
    if (isPenalty) return AppConstants.errorColor;
    if (isMotivational) return AppConstants.successColor;
    if (isSecondary) return AppConstants.warmBeige;
    return AppConstants.softBlue;
  }

  Color _getTextColor() {
    if (textColor != null) return textColor!;
    
    if (isOutlined) return AppConstants.softBlue;
    if (isPenalty) return Colors.white;
    if (isMotivational) return AppConstants.textPrimaryColor;
    return Colors.white; // White text on colored backgrounds for better contrast
  }
} 