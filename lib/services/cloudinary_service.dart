import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  final String cloudName = "stkc4y4i";
  final String uploadPreset = "travel_buddies_preset";

  Future<String?> uploadImage(XFile imageFile) async {
    try {
      final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

      // For Web, we read the image as bytes
      final bytes = await imageFile.readAsBytes();

      var request = http.MultipartRequest("POST", url);
      request.fields['upload_preset'] = uploadPreset;
      
      // We add the bytes to the request
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: imageFile.name,
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);
        return jsonResponse['secure_url'];
      } else {
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}