import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class CloudinaryService {
  CloudinaryService._();

  static final CloudinaryService instance = CloudinaryService._();

  static const String _cloudName = 'c2wjhmb4';
  static const String _uploadPreset = 'lostly_images';

  Future<String> uploadImage(File imageFile) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri);

      request.fields['upload_preset'] = _uploadPreset;

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );

      final response = await request.send();

      final responseBody = await response.stream.bytesToString();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Image upload failed (${response.statusCode}): $responseBody',
        );
      }

      final data = jsonDecode(responseBody) as Map<String, dynamic>;

      final imageUrl = data['secure_url']?.toString();

      if (imageUrl == null || imageUrl.isEmpty) {
        throw Exception('Cloudinary did not return an image URL.');
      }

      return imageUrl;
    } catch (e) {
      throw Exception('Could not upload image: $e');
    }
  }
}