import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fitcheck/pages/startpage.dart';
import 'package:fitcheck/pages/gsusername.dart';


class PETGettingStartedWidget extends StatefulWidget {
  const PETGettingStartedWidget({super.key});

  @override
  State<PETGettingStartedWidget> createState() => _PETGettingStartedWidgetState();
}

class _PETGettingStartedWidgetState extends State<PETGettingStartedWidget> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<Color> dotColors = [
    Color(0xFFFFBA76),
    Color(0xFFFFFFFF),
    Color(0xFFFFFFFF),
    Color(0xFFFFFFFF),
    Color(0xFFFFFFFF),
  ];

  @override
  void dispose() {
    _textController.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/images/background.png'),
          ),
        ),
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PreferredSize(
                preferredSize: const Size.fromHeight(80),
                child: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  centerTitle: true,
                  title: const Padding(
                    padding: EdgeInsets.only(top: 15.0),
                    child: Text(
                      'PAWPRINT',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFBA76),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFBA76),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Please Enter Your\nEmail!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 350,
                          child: TextFormField(
                            controller: _textController,
                            focusNode: _textFieldFocusNode,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                            ),
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                              hintText: 'email...',
                              hintStyle: const TextStyle(
                                color: Colors.white70,
                                fontSize: 30,
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const StarterPage(),
                                      ),
                                    );
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.arrowLeft,
                        size: 25,
                        color: Color(0xFFFFBA76),
                      ),
                      label: const Text(''),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        elevation: 0,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        dotColors.length,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: dotColors[index],
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PETGettingStartedP2Widget(
        email: _textController.text,
      ),
    ),
  );
},

                      icon: const FaIcon(
                        FontAwesomeIcons.arrowRight,
                        size: 25,
                        color: Color(0xFFFFBA76),
                      ),
                      label: const Text(''),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
