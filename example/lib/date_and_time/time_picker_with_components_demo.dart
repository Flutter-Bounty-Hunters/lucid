import 'package:flutter/widgets.dart';
import 'package:lucid/lucid.dart';

class TimePickerWithComponentsDemo extends StatefulWidget {
  const TimePickerWithComponentsDemo({super.key});

  @override
  State<TimePickerWithComponentsDemo> createState() => _TimePickerWithComponentsDemoState();
}

class _TimePickerWithComponentsDemoState extends State<TimePickerWithComponentsDemo> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 600),
        child: Column(
          spacing: 8,
          children: [
            Spacer(),
            _buildTimePickerDemo(TimeResolution.second),
            const SizedBox(height: 100),
            Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerDemo(TimeResolution resolution) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 54),
      child: _TimePickerDemo(
        resolution: resolution,
      ),
    );
  }
}

class _TimePickerDemo extends StatefulWidget {
  const _TimePickerDemo({
    this.resolution,
  });

  final TimeResolution? resolution;

  @override
  State<_TimePickerDemo> createState() => _TimePickerDemoState();
}

class _TimePickerDemoState extends State<_TimePickerDemo> {
  LocalTime? _time;

  @override
  Widget build(BuildContext context) {
    return TimePicker(
      value: _time,
      timeResolution: widget.resolution ?? TimeResolution.second,
      onNewTimeRequested: (newTime) {
        setState(() {
          _time = newTime;
        });
      },
    );
  }
}
