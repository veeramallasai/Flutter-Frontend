import 'package:flutter/material.dart';

class ShimmerLoader extends StatefulWidget {
  const ShimmerLoader({
    super.key,
    this.height = 120,
    this.width = double.infinity,
    this.borderRadius = 18,
  });

  final double height;
  final double width;
  final double borderRadius;

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1250))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) => Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.5 + (_controller.value * 3), 0),
              end: Alignment(-0.5 + (_controller.value * 3), 0),
              colors: const <Color>[Color(0xFFE7EDE9), Color(0xFFF8FAF9), Color(0xFFE7EDE9)],
            ),
          ),
        ),
      );
}
