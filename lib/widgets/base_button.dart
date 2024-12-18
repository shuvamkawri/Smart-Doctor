import 'package:flutter/material.dart';

class BaseButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? buttonStyle;
  final TextStyle? buttonTextStyle;
  final bool? isDisabled;
  final double? height;
  final double? width;
  final EdgeInsets? margin;
  final Alignment? alignment;

  const BaseButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.buttonStyle,
    this.buttonTextStyle,
    this.isDisabled,
    this.height,
    this.width,
    this.margin,
    this.alignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: margin,
      alignment: alignment,
      child: ElevatedButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: Text(
          text,
          style: buttonTextStyle,
        ),
      ),
    );
  }
}
