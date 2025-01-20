import 'package:dartgpt/constant/constants.dart';
import 'package:flutter/material.dart';

class ModelsDropDown extends StatefulWidget {
  const ModelsDropDown({super.key});

  @override
  State<ModelsDropDown> createState() => _ModelsDropDownState();
}

class _ModelsDropDownState extends State<ModelsDropDown> {
  String currentModel = "Model1";
  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      dropdownColor: scaffoldBackgroundColor,
      iconEnabledColor: Colors.white,
      iconDisabledColor: Colors.white,
      
      style: TextStyle(color: const Color.fromARGB(255, 255, 254, 255)),
      items: getModelsItem,
    value: currentModel,
     onChanged: (value){
      setState(() {
        currentModel = value.toString();
      });
      
    });
  }
}