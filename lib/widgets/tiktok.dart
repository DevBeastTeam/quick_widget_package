import 'package:flutter/material.dart';

class QuickTikTokLoader extends StatefulWidget {
  final double width;
  final double height;
  final Color backgroundColor;
  final Color progressColor;
  final Duration animationDuration;
  final BorderRadius? borderRadius;

  const QuickTikTokLoader({
    super.key,
    this.width = double.infinity,
    this.height = 2.0,
    this.backgroundColor = const Color(0x33FFFFFF),
    this.progressColor = Colors.blue, // ✅ Default color changed here
    this.animationDuration = const Duration(milliseconds: 500),
    this.borderRadius,
  });

  @override
  State<QuickTikTokLoader> createState() => _QuickTikTokLoaderState();
}

class _QuickTikTokLoaderState extends State<QuickTikTokLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.repeat(reverse: false);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius:
            widget.borderRadius ?? BorderRadius.circular(widget.height / 2),
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return ClipRRect(
            borderRadius:
                widget.borderRadius ?? BorderRadius.circular(widget.height / 2),
            child: Stack(
              children: [
                // Progress bar that expands from center
                Center(
                  child: Container(
                    width: (widget.width == double.infinity
                            ? MediaQuery.of(context).size.width // ✅ screen size
                            : widget.width) *
                        _animation.value,
                    height: widget.height,
                    decoration: BoxDecoration(
                      color: widget.progressColor,
                      borderRadius: widget.borderRadius ??
                          BorderRadius.circular(widget.height / 2),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
