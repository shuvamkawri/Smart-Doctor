import 'package:flutter/material.dart';

class CustomImageWidget extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final double? borderRadius;
  final Color? color;
  final Alignment? alignment;
  final VoidCallback? onTap;
  final List<BoxShadow> boxShadow;
  final EdgeInsetsGeometry? margin;
  final BoxBorder? border;
  final BoxFit? fit;
  final String? child;

  CustomImageWidget({
    required this.imagePath,
    this.width,
    this.height,
    this.borderRadius,
    this.color,
    this.alignment,
    this.onTap,
    this.boxShadow = const [],
    this.margin,
    this.border,
    this.fit,
    this.child
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius != null ? BorderRadius.circular(borderRadius!) : null,
        boxShadow: boxShadow,
        border: border,
        color: color,
      ),
      child: ClipRRect(
        // borderRadius: borderRadius != null ? BorderRadius.circular(borderRadius!) : null,
        child: GestureDetector(
          onTap: onTap,
          child: Image.asset(
            imagePath,
            fit: fit,
            alignment: alignment ?? Alignment.center,
          ),
        ),
      ),
    );
  }
}
