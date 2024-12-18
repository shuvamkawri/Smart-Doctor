import 'package:flutter/material.dart';

import 'base_button.dart';

class CustomElevatedButton extends BaseButton {
  final BoxDecoration? decoration;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final Color? color;

  CustomElevatedButton( {
    Key? key,
    this.decoration,
    this.color,
    this.leftIcon,
    this.rightIcon,
    EdgeInsets? margin,
    required VoidCallback? onPressed,
    ButtonStyle? buttonStyle,
    Alignment? alignment,
    TextStyle? buttonTextStyle,
    bool? isDisabled,
    double? height,
    double? width,
    required String text,
  }) : super(
    key: key,
    text: text,
    onPressed: onPressed,
    buttonStyle: buttonStyle,
    isDisabled: isDisabled,
    buttonTextStyle: buttonTextStyle,
    height: height,
    width: width,
    alignment: alignment,
    margin: margin,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: margin,
      color: color,
      alignment: alignment,
      child: ElevatedButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leftIcon != null) leftIcon!,
            SizedBox(width: leftIcon != null ? 8.0 : 0.0),
            Text(
              text,
              style: buttonTextStyle,
            ),
            SizedBox(width: rightIcon != null ? 8.0 : 0.0),
            if (rightIcon != null) rightIcon!,
          ],
        ),
      ),
    );
  }
}
