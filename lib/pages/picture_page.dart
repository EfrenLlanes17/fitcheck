import 'package:flutter/material.dart';


class PicturePage extends StatelessWidget {
  const PicturePage({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Picture Page")),
      body: Center(
        child: Text("Hello"),
      )
    );
  }
}
