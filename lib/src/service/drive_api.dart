import 'package:event_management/src/service/logger_service.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

Future<String> loadClientSecret() async {
  return await rootBundle.loadString('assets/json/client_secret.json');
}

Future<void> authenticateAndUpload(
    String folderName, String localFilePath) async {
  try {
    var credentials =
        ServiceAccountCredentials.fromJson(await loadClientSecret());

    var scopes = [drive.DriveApi.driveFileScope];

    // Authenticate and upload the file
    await clientViaServiceAccount(credentials, scopes).then((authClient) async {
      var driveApi = drive.DriveApi(authClient);

      // Check if the folder exists, and create it if not
      String? folderId = await getOrCreateFolder(driveApi, folderName);

      await uploadFile(driveApi, folderId!, localFilePath);
      authClient.close();
    });
  } catch (e) {
    LoggerService.logger.e('Authentication or upload failed: $e');
    throw Exception('Error uploading file');
  }
}

Future<String?> getOrCreateFolder(
    drive.DriveApi driveApi, String folderName) async {
  try {
    // List files and folders in Google Drive
    var fileList = await driveApi.files.list(
        q: "mimeType='application/vnd.google-apps.folder' and name='$folderName'");

    if (fileList.files!.isNotEmpty) {
      // Folder exists, return the folder ID
      return fileList.files?.first.id!;
    } else {
      // Folder does not exist, create it
      var folder = drive.File()
        ..name = folderName
        ..mimeType = 'application/vnd.google-apps.folder';

      var response = await driveApi.files.create(folder);
      LoggerService.logger.i('Created folder: ${response.name}');
      return response.id!;
    }
  } catch (e) {
    LoggerService.logger.e('Error checking/creating folder: $e');
    rethrow;
  }
}

// ignore: body_might_complete_normally_nullable
Future<String?> uploadFile(
    drive.DriveApi driveApi, String folderId, String localFilePath) async {
  try {
    var fileName = localFilePath.split('/').last;

    var file = drive.File()
      ..parents = [folderId]
      ..name = fileName;

    var fileContent = File(localFilePath);
    var media = drive.Media(fileContent.openRead(), fileContent.lengthSync());

    var response = await driveApi.files.create(file, uploadMedia: media);

    var fileId = response.id;

    var permission = drive.Permission()
      ..type = 'anyone'
      ..role = 'reader';
    await driveApi.permissions.create(permission, fileId!);

    var fileLink = response.webViewLink ?? response.webContentLink;

    LoggerService.logger.i('Uploaded: ${response.name}');
    LoggerService.logger.i('File URL: $fileLink');
    return fileLink;
  } catch (e) {
    LoggerService.logger.e('Error uploading file: $e');
  }
}
