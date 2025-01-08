import 'dart:convert';
import 'dart:io';
import 'package:event_management/config.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

Future<String> uploadFileToImageKit(
    File file, String folder, String fileName) async {
  const privateKey = 'private_F801T1Ot8g2c8BCrrN+7+y+Kvdc=';
  final base64EncodedKey = base64Encode(utf8.encode('$privateKey:'));

  final request = http.MultipartRequest(
    'POST',
    Uri.parse('https://upload.imagekit.io/api/v1/files/upload'),
  );
  request.headers['Authorization'] = 'Basic $base64EncodedKey';
  request.files.add(await http.MultipartFile.fromPath('file', file.path));

  request.fields['fileName'] = fileName;
  request.fields['useUniqueFileName'] = 'false';
  request.fields['folder'] = folder;

  final response = await request.send();

  if (response.statusCode == 200) {
    final responseData = await response.stream.bytesToString();
    final decodedData = json.decode(responseData);
    final fileUrl = decodedData['url'];

    LoggerService.logger.i("File uploaded successfully. URL: $fileUrl");

    return fileUrl;
  } else {
    final responseData = await response.stream.bytesToString();
    LoggerService.logger
        .e('Failed to upload file: ${response.statusCode}, $responseData');
    throw Exception('Failed to upload file ${response.statusCode}');
  }
}

/// Uploads a document for a specific event.
Future<void> uploadDocument(int eventId, String fileName, String fileUrl,
    String contentType, int size) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    String? idToken = await user.getIdToken();
    if (idToken == null) {
      throw Exception('Failed to retrieve ID token');
    }

    final response = await http.post(
      Uri.parse(
          '${Config.baseUrl}/document-service/event/$eventId/documents/add'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'FileName': fileName,
        'Url': fileUrl,
        'Size': size,
        'ContentType': contentType,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to upload document; status: ${response.statusCode}, body: ${response.body}');
    }

    final responseData = json.decode(response.body);
    if (responseData['success'] == true) {
      LoggerService.logger.i('Document uploaded successfully');
    } else {
      throw Exception('Failed to upload document: ${response.body}');
    }
  } catch (e) {
    LoggerService.logger.e('Failed to upload document: $e');
  }
}

Future<List<Map<String, dynamic>>> fetchDocuments(int eventId) async {
  try {
    LoggerService.logger.i('Fetching documents for eventId: $eventId');

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      LoggerService.logger.e('No user logged in');
      throw Exception('No user logged in');
    }

    String? idToken = await user.getIdToken();
    if (idToken == null) {
      LoggerService.logger.e('Failed to retrieve ID token');
      throw Exception('Failed to retrieve ID token');
    }

    LoggerService.logger.i('ID Token retrieved successfully');

    final response = await http.get(
      Uri.parse('${Config.baseUrl}/document-service/event/$eventId/documents'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      LoggerService.logger.i('Successfully fetched documents');

      Map<String, dynamic> data = json.decode(response.body);
      if (data['success'] == false) {
        LoggerService.logger.e('No documents found for eventId $eventId');
        return [];
      }

      List<Map<String, dynamic>> documents = [];
      for (var item in data['data']) {
        documents.add(item);
      }

      LoggerService.logger.i('Documents fetched: ${documents.length}');
      return documents;
    } else {
      LoggerService.logger.e('Failed to fetch documents: ${response.body}');
      throw Exception('Failed to fetch documents: ${response.body}');
    }
  } catch (e) {
    LoggerService.logger.e('Error fetching documents: $e');
    return [];
  }
}

/// Deletes a document by its ID.
Future<void> deleteDocument(int eventId, String documentId) async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    String? idToken = await user.getIdToken();
    if (idToken == null) {
      throw Exception('Failed to retrieve ID token');
    }
    LoggerService.logger.i("documentid: $documentId");
    final response = await http.delete(
      Uri.parse(
          '${Config.baseUrl}/document-service/event/$eventId/documents/$documentId/delete'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to delete document: ${response.body}, status: ${response.statusCode}');
    }

    final responseData = json.decode(response.body);
    if (responseData['success'] == true) {
      LoggerService.logger.i('Document deleted successfully');
    } else {
      throw Exception(
          'Failed to delete document2: ${response.body}, status: ${response.statusCode}');
    }
  } catch (e) {
    LoggerService.logger.e('Error deleting document: $e');
  }
}
