// Clean version of PETGettingStartedP2Widget without FlutterFlow or Google Fonts
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fitcheck/pages/startpage.dart';
import 'package:fitcheck/pages/gsemail.dart';
import 'package:fitcheck/pages/gsusername.dart';
import 'package:fitcheck/pages/gspassword.dart';
import 'package:fitcheck/pages/gslocation.dart';
import 'package:fitcheck/pages/countcontol.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fitcheck/pages/gsamountofpets.dart';
import 'package:fitcheck/pages/petinfo.dart';






class PETGettingStartedP7Widget extends StatefulWidget {
  final String email;
  final String username; 
  final String password;
  final String location;
  final int amountofpets;
  final List<List<String>> petInfo;
  const PETGettingStartedP7Widget({super.key, required this.email, required this.username, required this.password, required this.location, required this.amountofpets, required this.petInfo});

  

  @override
  State<PETGettingStartedP7Widget> createState() => _PETGettingStartedP7WidgetState();
}

class _PETGettingStartedP7WidgetState extends State<PETGettingStartedP7Widget> {
  final TextEditingController _textController = TextEditingController();
    final TextEditingController textController1 = TextEditingController();
  String? selectedGender;
    String? selectedPet;
    Set<String> selectedPets = {};
    final List<String> petOptions = [
  'Bird', 'Cat', 'Chicken', 'Chinchilla', 'Cow', 'Crab', 'Dog', 'Donkey',
  'Duck', 'Eel', 'Ferret', 'Fish', 'Frog', 'Gecko', 'Gerbil', 'Goat',
  'Goose', 'Guinea pig', 'Hamster', 'Hedgehog', 'Horse', 'Iguana', 'Insect',
  'Lizard', 'Lobster', 'Lynx', 'Monkey', 'Mouse', 'Pig', 'Rabbit', 'Raccoon',
  'Rat', 'Salamander', 'Sheep', 'Shrimp', 'Snake', 'Spider', 'Turtle',
];

    TextEditingController breedController = TextEditingController();
FocusNode breedFocusNode = FocusNode();



  final FocusNode textFieldFocusNode1 = FocusNode();
  final FocusNode _textFieldFocusNode = FocusNode();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int yourCountVariable = 1;
    String? Function(String?)? textController1Validator;


  List<Color> dotColors = [
  Color(0xFFFFBA76),
  Color(0xFFFFBA76),
  Color(0xFFFFBA76),
  Color(0xFFFFBA76),
  Color(0xFFFFBA76),
  Color(0xFFFFBA76),
  Color(0xFFFFBA76),

];

 @override
  void initState() {
    super.initState();
    textController1Validator = (value) {
      if (value == null || value.isEmpty) {
        return 'Please enter a name';
      }
      return null;
    };
  }

  @override
  void dispose() {
    textController1.dispose();
    textFieldFocusNode1.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey[600], fontSize: 17),
    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.orange, width: 1),
      borderRadius: BorderRadius.circular(8),
    ),
  );
}


    Widget _buildLabeledField(String label, Widget field) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 150,

          padding: const EdgeInsets.only(left: 16, top: 0),
          child: Text(
            label,
            style: TextStyle(
              
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: field,
          ),
        ),
      ],
    ),
  );
}



TextStyle _inputTextStyle() => TextStyle(
      color: Color(0xFFFFBA76),
      fontSize: 17,
    );



 @override
Widget build(BuildContext context) {
  print(widget.email + " " + widget.username + " " + widget.password + " " + widget.location + " " + widget.amountofpets.toString());
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
                child: Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    // White title box directly above orange box
    Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Center(
        child: Text(
          'What do you want to see?',
          style: TextStyle(
            color: Color(0xFFFFBA76),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),

    // Orange form container attached directly below
    Container(
  width: MediaQuery.of(context).size.width * 0.85,
  decoration: BoxDecoration(
    color: Color(0xFFFFBA76),
    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
    border: Border.all(color: Color(0xFFFFBA76), width: 2),
  ),
  padding: const EdgeInsets.all(16),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: petOptions.map((pet) {
          final isSelected = selectedPets.contains(pet);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  selectedPets.remove(pet);
                } else {
                  selectedPets.add(pet);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                pet,
                style: TextStyle(
                  color: isSelected ? Color(0xFFFFBA76) : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),

      const SizedBox(height: 24), // space above the button

      SizedBox(
        width: double.infinity, // make it full width
        height: 48,
        child: ElevatedButton(
          onPressed: () {
            // Add your logic here
            print('Selected pets: $selectedPets');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Done',
            style: TextStyle(
              color: Color(0xFFFFBA76),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ],
  ),
)


  ],
)



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
      builder: (context) => PETGettingStartedP6Widget(
        email: widget.email, username: widget.username, password: widget.password, location: widget.location, amountofpets:widget.amountofpets,
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
        print('Next button pressed');
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
