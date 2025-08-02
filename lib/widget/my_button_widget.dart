import 'package:flutter/material.dart';

import 'my_text_widget.dart';

// ignore: must_be_immutable
class MyButton extends StatelessWidget {
  MyButton({
    required this.buttonText,
    required this.onTap,
    this.height = 48,
    this.textSize,
    this.weight,
    this.radius,
    this.customChild,
    this.bgColor,
    this.textColor,
    this.isLoading,
  });

  final String buttonText;
  final VoidCallback onTap;
  double? height, textSize, radius;
  FontWeight? weight;
  Widget? customChild;
  Color? bgColor, textColor;
  final bool? isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? 16),
        color: bgColor,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius ?? 16),
          child:
              customChild ??
              Center(
                child: (isLoading != null && isLoading!)
                    ? CircularProgressIndicator(color: Colors.white)
                    : MyText(
                        text: buttonText,
                        size: textSize ?? 16,
                        weight: weight ?? FontWeight.w600,
                        color: textColor,
                      ),
              ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class MyBorderButton extends StatelessWidget {
  MyBorderButton({
    required this.buttonText,
    required this.onTap,
    this.height = 48,
    this.textSize,
    this.weight,
    this.child,
    this.radius,
    this.borderColor,
  });

  final String buttonText;
  final VoidCallback onTap;
  double? height, textSize;
  FontWeight? weight;
  Widget? child;
  double? radius;
  Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? 16),
        color: Colors.transparent,
        border: Border.all(width: 1.0, color: borderColor ?? Colors.grey),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius ?? 16),
          child:
              child ??
              Center(
                child: MyText(
                  text: buttonText,
                  size: textSize ?? 16,
                  weight: weight ?? FontWeight.w600,
                ),
              ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class MyToggleButton extends StatelessWidget {
  MyToggleButton({
    required this.buttonText,
    required this.onTap,
    required this.isSelected,
  });

  final String buttonText;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(width: 1.0, color: Colors.grey),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          // splashColor: isSelected
          //     ? kPrimaryColor.withOpacity(0.1)
          //     : kSecondaryColor.withOpacity(0.1),
          // highlightColor: isSelected
          //     ? kPrimaryColor.withOpacity(0.1)
          //     : kSecondaryColor.withOpacity(0.1),
          // borderRadius: BorderRadius.circular(50),
          child: Center(
            child: MyText(
              text: buttonText,
              size: 14,
              lineHeight: null,
              weight: FontWeight.w600,
              // color: isSelected ? kPrimaryColor : kSecondaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
