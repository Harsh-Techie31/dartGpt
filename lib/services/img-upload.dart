import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data'; // For Uint8List
import 'package:image/image.dart' as img; // For local image processing
import 'package:uuid/uuid.dart';

var uuid = Uuid();

Future<String?> uploadImageToCloudinary(Uint8List imageData) async {
  final String cloudName = 'duj0vjomg'; // Replace with your Cloudinary cloud name
  final String uploadPreset = 'ydejjwe0'; // Replace with your unsigned upload preset

  // Compress and resize the image locally before upload
  Uint8List compressedImageData = compressAndResizeImage(imageData);

  final Uri uploadUrl = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

  // Prepare the image and other data for the POST request
  var request = http.MultipartRequest('POST', uploadUrl)
    ..fields['upload_preset'] = uploadPreset
    ..files.add(http.MultipartFile.fromBytes(
      'file',
      compressedImageData,
      filename: 'compressed_image.jpg',
    ))
    ..headers.addAll({
      'Content-Type': 'multipart/form-data',
    });

  try {
    // Send the request
    final response = await request.send();
    if (response.statusCode == 200) {
      // Parse the response and get the image URL
      final resp = await http.Response.fromStream(response);
      final Map<String, dynamic> result = json.decode(resp.body);

      // Apply Cloudinary transformations to optimize the delivery URL
      final String optimizedImageUrl = applyCloudinaryTransformations(result['secure_url']);
      return optimizedImageUrl;
    } else {
      print('Failed to upload image: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error: $e');
    return null;
  }
}

// Function to compress and resize the image locally
Uint8List compressAndResizeImage(Uint8List imageData) {
  final img.Image originalImage = img.decodeImage(imageData)!;

  // Resize the image to a maximum width of 800px (maintains aspect ratio)
  final img.Image resizedImage = img.copyResize(originalImage, width: 800);

  // Compress the image to 75% quality
  final Uint8List compressedImageData = Uint8List.fromList(
    img.encodeJpg(resizedImage, quality: 75),
  );

  return compressedImageData;
}

// Function to apply Cloudinary transformations to the uploaded URL
String applyCloudinaryTransformations(String imageUrl) {
  // Replace 'upload/' with 'upload/w_800,h_800,q_auto,f_auto/' in the URL
  return imageUrl.replaceFirst(
    'upload/',
    'upload/w_800,h_800,q_auto,f_auto/',
  );
}
