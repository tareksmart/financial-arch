import 'package:flutter/material.dart';
import '../theme/index.dart';
import 'dart:ui';


/// Signature "Pulse Card" component for displaying balance summary
class PulseCard extends StatelessWidget {
  final String title;
  final String amount;
  final String currency;
  final String? subtitle;
  final Color backgroundColor;
  final Widget? child;
  final EdgeInsets padding;

  const PulseCard({
    Key? key,
    required this.title,
    required this.amount,
    required this.currency,
    this.subtitle,
    this.backgroundColor = AppColors.primary,
    this.child,
    this.padding = const EdgeInsets.all(32),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            backgroundColor,
            backgroundColor == AppColors.primary ? AppColors.primaryDark : backgroundColor,
          ],
          begin: const Alignment(1, 1),
          end: const Alignment(-1, -1),
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative background element
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // Content
          Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                // Amount
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: currency,
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(text: ' '),
                      TextSpan(
                        text: amount,
                        style: AppTextStyles.displaySmall.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
                if (child != null) ...[
                  const SizedBox(height: 24),
                  child!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Glass effect container with backdrop blur
class GlassEffect extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color backgroundColor;
  final double opacity;
  final double blurSigma;
  final BorderRadius? borderRadius;

  const GlassEffect({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor = AppColors.surface,
    this.opacity = 0.8,
    this.blurSigma = 16,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(opacity),
          borderRadius: borderRadius ?? BorderRadius.circular(16),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

// Import for image filter
