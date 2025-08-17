import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AppIconButton extends StatelessWidget {
  final String appName;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;
  final bool isBlocked;
  
  const AppIconButton({
    super.key,
    required this.appName,
    required this.icon,
    required this.onPressed,
    this.iconColor,
    this.isBlocked = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: isBlocked 
            ? AppConstants.stoneGray
            : AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: isBlocked 
              ? AppConstants.textTertiaryColor
              : AppConstants.softBlue,
          width: 2, // Increased border width
        ),
        boxShadow: AppConstants.mediumShadow, // More visible shadow
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Vibrant icon
              Icon(
                icon,
                size: 36, // Increased icon size
                color: isBlocked 
                    ? AppConstants.textTertiaryColor
                    : (iconColor ?? AppConstants.softBlue),
              ),
              
              const SizedBox(height: AppConstants.xsPadding),
              
              // App name with better visibility
              Flexible(
                child: Text(
                  appName,
                  style: AppConstants.captionStyle.copyWith(
                    fontSize: 12, // Increased font size
                    fontWeight: FontWeight.w700, // Increased weight
                    color: isBlocked 
                        ? AppConstants.textTertiaryColor
                        : AppConstants.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 