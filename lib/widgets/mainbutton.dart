import 'package:flutter/material.dart';
import 'dotloader.dart'; // agar DotLoader aapne alag banaya hai to import rakhein

class QuickButton extends StatelessWidget {
  final double width;
  final double radius;
  final Color bgColor;
  final Color textColor;
  final String text;
  final Widget? child;
  final double btnPadding;
  final double letterSpacing;
  final bool borderShow;

  final bool isLoading;
  final VoidCallback onPressed;

  const QuickButton({
    super.key,
    this.text = "",
    this.radius = 20,
    this.width = 0.9,
    this.bgColor = Colors.white,
    this.textColor = Colors.black,
    this.btnPadding = 11,
    this.letterSpacing = 3,
    this.borderShow = false,
    this.isLoading = false,
    this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;

    return InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: onPressed,
      child: Container(
        width: w * width,
        decoration: BoxDecoration(
          border: borderShow
              ? Border.all(color: Colors.blue)
              : null, // ✅ Default color set
          borderRadius: BorderRadius.circular(radius),
          color: bgColor,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: btnPadding),
            child: child ??
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: textColor,
                        letterSpacing: letterSpacing,
                      ),
                ),
          ),
        ),
      ),
    );
  }
}
