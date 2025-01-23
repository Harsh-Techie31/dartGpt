import 'package:dartgpt/models/model-models.dart';
import 'package:dartgpt/services/api-services.dart';
import 'package:flutter/widgets.dart';


class ModelsProvider  with ChangeNotifier{
  
  String currentModel = "gpt-4";  
  

  String get getCurrentModel{
    return currentModel;
  }

  void setCurrentModel(String newModel){
    currentModel = newModel;
    notifyListeners();
  }


  List <ModelsModel> modelList =[];

  List<ModelsModel> get getModelList{
    return modelList;
  }

  Future<List<ModelsModel>> getAllModels() async{
    modelList = await ApiService.getModels();
    return modelList;
  }
}