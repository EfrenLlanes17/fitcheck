import 'package:flutter/material.dart';


class CountController extends StatefulWidget {
  final int initialCount;
  final Function(int) onChanged;

  const CountController({
    super.key,
    required this.initialCount,
    required this.onChanged,
  });

  @override
  State<CountController> createState() => _CountControllerState();
}

class _CountControllerState extends State<CountController> {
  late int count;

  @override
  void initState() {
    super.initState();
    count = widget.initialCount;
  }

  void increment() {
    setState(() => count++);
    widget.onChanged(count);
  }

  void decrement() {
    setState(() {
      if (count > 1) count--;
    });
    widget.onChanged(count);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_rounded, color: Color.fromARGB(255, 255, 255, 255)),
            onPressed: decrement,
          ),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Color.fromARGB(255, 255, 255, 255)),
            onPressed: increment,
          ),
        ],
      ),
    );
  }
}
