import 'package:flutter/material.dart';

class BlinkingContainer extends StatefulWidget {
  final double width;
  final double height;

  const BlinkingContainer({Key? key, this.width = 100.0, this.height = 15.0})
      : super(key: key);

  @override
  _BlinkingContainerState createState() => _BlinkingContainerState();
}

class _BlinkingContainerState extends State<BlinkingContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = ColorTween(
      begin: Colors.grey[100],
      end: Colors.grey[200],
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: _animation.value,
          ),
          width: widget.width,
          height: widget.height,
        );
      },
    );
  }
}

class BlinckingDot extends StatefulWidget {
  final double width;
  final double height;

  const BlinckingDot({Key? key, this.width = 100.0, this.height = 15.0})
      : super(key: key);

  @override
  _BlinckingDotState createState() => _BlinckingDotState();
}

class _BlinckingDotState extends State<BlinckingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = ColorTween(
      begin: Colors.lightBlueAccent[100],
      end: Colors.blueAccent,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          children: [
            CircleAvatar(
              backgroundColor: _animation.value,
              radius: 6,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(TimeOfDay.now().format(context),
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))
          ],
        );
      },
    );
  }
}
