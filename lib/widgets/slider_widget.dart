import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Widget buildSlider({
  required String label,
  required double value,
  required double min,
  required double max,
  required ValueChanged<double> onChanged,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(label),
      Slider(
        
        value: value,
        min: min,
        max: max,
        onChanged: onChanged,
      ),
    ],
  );
}
