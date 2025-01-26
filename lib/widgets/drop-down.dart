import 'package:dartgpt/constant/constants.dart';
import 'package:dartgpt/models/model-models.dart';
import 'package:dartgpt/providers/model-proivder.dart';
import 'package:dartgpt/services/api-services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ModelsDropDown extends StatefulWidget {
  const ModelsDropDown({super.key});

  @override
  State<ModelsDropDown> createState() => _ModelsDropDownState();
}

class _ModelsDropDownState extends State<ModelsDropDown> {
  String? currentModel ; // Default model

  @override
  Widget build(BuildContext context) {

    final modelsProvider = Provider.of<ModelsProvider>(context , listen: false);
    currentModel = modelsProvider.getCurrentModel;
    return FutureBuilder<List<ModelsModel>>(
      future: modelsProvider.getAllModels(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 50, // Compact size for loading spinner
            child: Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "No Models Available",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          constraints: const BoxConstraints(maxWidth: 220), // Limit width
          child: DropdownButton<String>(
            isExpanded: true, // Allow full width
            dropdownColor: Colors.transparent,
            iconEnabledColor: Colors.white,
            value: currentModel,
            style: const TextStyle(color: Colors.white),
            items: snapshot.data!
                .map((model) => DropdownMenuItem<String>(
                      value: model.id,
                      child: Text(
                        model.id,
                        style: const TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            onChanged: (String? value) {
              setState(() {
                currentModel = value ?? currentModel;
              });
              modelsProvider.setCurrentModel(value.toString());
            },
          ),
        );
      },
    );
  }
}
