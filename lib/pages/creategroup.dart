import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fitcheck/pages/group_page.dart';

class PETEditGroupWidget extends StatefulWidget {
  const PETEditGroupWidget({super.key});

 
  @override
  State<PETEditGroupWidget> createState() => _PETEditGroupWidgetState();
}

class _PETEditGroupWidgetState extends State<PETEditGroupWidget> {
  final _groupNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _privacySelection;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _groupNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFFFBA76);
    const white = Colors.white;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: white,
      body: SafeArea(
  child: SingleChildScrollView(
    padding: EdgeInsets.only(
      bottom: MediaQuery.of(context).viewInsets.bottom + 20,
    ),
    child:Column(
        children: [
          SafeArea(
  child: Container(
    color: white,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    child: Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: orange),
          onPressed: () {
            Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const GroupPage()),
                );
          },
        ),
        const Expanded(
          child: Center(
            child: Text(
              'Create a Pack',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: orange,
              ),
            ),
          ),
        ),
        const SizedBox(width: 48), // Space holder to balance layout
      ],
    ),
  ),
),

          Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1559311648-d46f5d8593d6?auto=format&fit=crop&w=1080&q=80',
                    width: 400,
                    height: 275,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: white,
                ),
                onPressed: () {
                  print('Upload Banner');
                },
                child: const Text('Upload Banner'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: TextFormField(
              controller: _groupNameController,
                style: const TextStyle(color: orange), // Add this line
              decoration: InputDecoration(
                labelText: 'Group Name',
                labelStyle: const TextStyle(color: orange),
                filled: true,
                fillColor: white,
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: orange, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: orange, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Public or Private',
                labelStyle: const TextStyle(color: orange),
                filled: true,
                fillColor: white,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: orange, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: orange, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: orange),
              value: _privacySelection,
              items: ['Public', 'Private'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(color: orange)),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _privacySelection = val;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              style: const TextStyle(color: orange), // Add this line
              decoration: InputDecoration(
                hintText: 'Description',
                hintStyle: const TextStyle(color: orange),
                filled: true,
                fillColor: white,
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: orange, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: orange, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: orange,
    foregroundColor: white,
    minimumSize: const Size(300, 64), // wider and more square-like
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  ),
  onPressed: () {
    print('Create Group');
  },
  child: const Text('Create Group'),
),

          ),
        ],
      ),
  ),
      ),
    );
  }
}
