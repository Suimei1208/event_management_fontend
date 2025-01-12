import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:event_management/src/service/logger_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
Future<String> uploadImageToImageKitWebVersion(String base64ImageData) async {
  const privateKey = 'private_F801T1Ot8g2c8BCrrN+7+y+Kvdc=';
  final base64EncodedKey = base64Encode(utf8.encode('$privateKey:'));
  User? user = FirebaseAuth.instance.currentUser;

  // Remove the base64 prefix if it exists (data:image/jpeg;base64,)
  String imageData = base64ImageData.replaceFirst(
      RegExp(r"^data:image\/[a-zA-Z]+;base64,"), "");

  // Create a FormData object to upload the image as multipart form data
  final request = html.FormData();

  // Convert the cleaned base64 image data to Blob
  final imageBlob = html.Blob([base64Decode(imageData)]);

  // Append the file and other fields to the request
  request.appendBlob('file', imageBlob, 'profile_pic_${user!.uid}.jpg');
  request.append('fileName', 'profile_pic_${user.uid}.jpg');
  request.append('useUniqueFileName', 'false');
  request.append('folder', '/profile_pictures');

  // Create an XMLHttpRequest to send the form data
  final xhr = html.HttpRequest();
  final uri = Uri.parse('https://upload.imagekit.io/api/v1/files/upload');
  xhr.open('POST', uri.toString());
  xhr.setRequestHeader('Authorization', 'Basic $base64EncodedKey');

  // Send the request and handle the response
  final completer = Completer<String>();
  xhr.onLoadEnd.listen((e) {
    if (xhr.status == 200) {
      final response = json.decode(xhr.responseText!);
      final imageUrl = response['url'];
      LoggerService.logger.i("Image uploaded successfully. URL: $imageUrl");
      completer.complete(imageUrl);
    } else {
      LoggerService.logger
          .e('Failed to upload image: ${xhr.status}, ${xhr.responseText}');
      completer.completeError('Failed to upload image');
    }
  });

  xhr.send(request);

  return completer.future;
}