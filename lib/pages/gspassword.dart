// Clean version of PETGettingStartedP2Widget without FlutterFlow or Google Fonts
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fitcheck/pages/startpage.dart';
import 'package:fitcheck/pages/gsemail.dart';
import 'package:fitcheck/pages/gsusername.dart';
import 'package:fitcheck/pages/gslocation.dart';




class PETGettingStartedP3Widget extends StatefulWidget {
  final String email;
  final String username;
  const PETGettingStartedP3Widget({super.key, required this.email, required this.username});

  

  @override
  State<PETGettingStartedP3Widget> createState() => _PETGettingStartedP3WidgetState();
}

class _PETGettingStartedP3WidgetState extends State<PETGettingStartedP3Widget> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<Color> dotColors = [
  Color(0xFFFFBA76),
  Color(0xFFFFBA76),
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
  print(widget.email + " " + widget.username);
  return GestureDetector(
    onTap: () => FocusScope.of(context).unfocus(),
    child: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage(
            'assets/images/background.png',
          ),
        ),
      ),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.transparent, // So image is visible
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           PreferredSize(
  preferredSize: Size.fromHeight(80), // Height of the AppBar
  child: AppBar(
    automaticallyImplyLeading: false, // 👈 Removes the back arrow
    backgroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    title: Padding(
      padding: const EdgeInsets.only(top: 15.0),
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
                    color: Color(0xFFFFBA76),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'What Should Your \nPassword Be?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: 350,
                        child: TextFormField(
                          controller: _textController,
                          focusNode: _textFieldFocusNode,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                          ),
                          decoration: InputDecoration(
                            hintText: 'password...',
                            hintStyle: TextStyle(
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
      builder: (context) => PETGettingStartedP2Widget(
        email: widget.email
      ),
    ),
  );
      },
      icon: FaIcon(
        FontAwesomeIcons.arrowLeft,
        size: 25,
        color: Color(0xFFFFBA76),
      ),
      label: Text(''),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20),
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
        width: 14,
        height: 14,
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
      builder: (context) => PETGettingStartedP4Widget(
        email: widget.email, username: widget.username, password: _textController.text
      ),
    ),
  );
      },
      icon: FaIcon(
        FontAwesomeIcons.arrowRight,
        size: 25,
        color: Color(0xFFFFBA76),
      ),
      label: Text(''),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20),
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
