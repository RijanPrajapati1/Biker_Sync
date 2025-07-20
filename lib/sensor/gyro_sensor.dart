import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class GyroscopeTiltView extends StatefulWidget {
  final Widget child;
  final double maxTiltAngle;
  final double sensitivity;

  const GyroscopeTiltView({
    super.key,
    required this.child,
    this.maxTiltAngle = 15.0,
    this.sensitivity = 1.5,
  });

  @override
  State<GyroscopeTiltView> createState() => _GyroscopeTiltViewState();
}

class _GyroscopeTiltViewState extends State<GyroscopeTiltView> {
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  double _rotationX = 0.0;
  double _rotationY = 0.0;

  @override
  void initState() {
    super.initState();
    _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        // Limit the rotation angles to prevent extreme tilting
        _rotationX = (_rotationX + event.y * widget.sensitivity).clamp(
          -widget.maxTiltAngle,
          widget.maxTiltAngle,
        );
        _rotationY = (_rotationY + event.x * widget.sensitivity).clamp(
          -widget.maxTiltAngle,
          widget.maxTiltAngle,
        );
      });
    });
  }

  @override
  void dispose() {
    _gyroscopeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform:
          Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..rotateX(_rotationX * math.pi / 180)
            ..rotateY(_rotationY * math.pi / 180),
      child: widget.child,
    );
  }
}
