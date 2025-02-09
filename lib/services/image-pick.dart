import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

Future<Uint8List?> pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _file = await _imagePicker.pickImage(source: source , imageQuality: 20);

  if (_file != null) {
    return await _file.readAsBytes();
  }
  
  // print('No image selected');
  return null;
}


