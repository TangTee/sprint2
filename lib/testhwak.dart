import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:tangteevs/admin/user/user.dart';
import 'package:tangteevs/pickers/block_picker.dart';
import 'package:tangteevs/pickers/hsv_picker.dart';
import 'package:tangteevs/pickers/material_picker.dart';
import 'package:tangteevs/utils/color.dart';

class testColor extends StatefulWidget {
  const testColor({super.key});

  @override
  State<testColor> createState() => _testColorState();
}

class _testColorState extends State<testColor> {
  bool lightTheme = true;
  Color currentColor = purple;
  List<Color> colorHistory = [];

  void changeColor(Color color) => setState(() => currentColor = color);

  @override
  Widget build(BuildContext context) {
    final foregroundColor =
        useWhiteForeground(currentColor) ? Colors.white : Colors.black;
    return AnimatedTheme(
      data: lightTheme ? ThemeData.light() : ThemeData.dark(),
      child: Builder(builder: (context) {
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => setState(() => lightTheme = !lightTheme),
            icon: Icon(lightTheme
                ? Icons.dark_mode_rounded
                : Icons.light_mode_rounded),
            label: Text(lightTheme ? 'Night' : '  Day '),
            backgroundColor: currentColor,
            foregroundColor: foregroundColor,
            elevation: 15,
          ),
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: mobileSearchColor,
                size: 30,
              ),
              onPressed: () => {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UserPage(),
                  ),
                )
              },
            ),
            title: const Text('Flutter Color Picker Example'),
            backgroundColor: currentColor,
            foregroundColor: foregroundColor,
          ),
          body: HSVColorPickerExample(
            pickerColor: currentColor,
            onColorChanged: changeColor,
            colorHistory: colorHistory,
            onHistoryChanged: (List<Color> colors) => colorHistory = colors,
          ),
        );
      }),
    );
  }
}
