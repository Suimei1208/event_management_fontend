// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';
import 'dart:typed_data';
import 'package:event_management/src/service/document_service.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:event_management/src/service/user_service_web.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class WebEventResourcesPage extends StatefulWidget {
  final int eventId;

  const WebEventResourcesPage({super.key, required this.eventId});
  static const routeName = "/home/event-detail/documents";

  @override
  _WebEventResourcesPageState createState() => _WebEventResourcesPageState();
}

class _WebEventResourcesPageState extends State<WebEventResourcesPage> {
  List<Map<String, dynamic>> documents = [];
  List<Map<String, dynamic>> images = [];
  List<Map<String, dynamic>> videos = [];
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    fetchResources();
  }

  Future<void> fetchResources() async {
    try {
      final fetchedDocuments = await fetchDocuments(widget.eventId);
      LoggerService.logger.i('Fetched documents: $fetchedDocuments');
      setState(() {
        documents = fetchedDocuments
            .where((doc) => doc['contentType'] == 'document')
            .toList();
        images = fetchedDocuments
            .where((doc) => doc['contentType'] == 'image')
            .toList();
        videos = fetchedDocuments
            .where((doc) => doc['contentType'] == 'video')
            .toList();
      });
    } catch (e) {
      LoggerService.logger.e('Error fetching resources: $e');
    }
  }

  Future<void> handleFileUpload(String folder, String type) async {
    setState(() {
      isUploading = true;
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: type == 'image'
          ? ['jpg', 'jpeg', 'png']
          : type == 'video'
              ? ['mp4']
              : ['txt', 'pdf', 'pptx'],
    );

    if (result != null) {
      Uint8List fileBytes = result.files.first.bytes!;
      String fileName = result.files.first.name;

      if (type == 'image' && fileBytes.length > 4 * 1024 * 1024) {
        LoggerService.logger.e('Image size exceeds 4MB.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image size must not exceed 4MB.')),
        );
        setState(() {
          isUploading = false;
        });
        return;
      } else if (type == 'video' && fileBytes.length > 50 * 1024 * 1024) {
        LoggerService.logger.e('Video size exceeds 50MB.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video size must not exceed 50MB.')),
        );
        setState(() {
          isUploading = false;
        });
        return;
      }

      String base64ImageData = base64Encode(fileBytes);
      String contentType = type;

      try {
        String fileUrl = await uploadDocumentsToImageKitWebVersion(
            base64ImageData, folder, fileName);

        await uploadDocument(
            widget.eventId, fileName, fileUrl, contentType, fileBytes.length);

        fetchResources();

        LoggerService.logger.i(
            "File added successfully: $fileName, size: ${fileBytes.length} bytes");
      } catch (e) {
        LoggerService.logger.e("Error uploading file: $e");
      }
    } else {
      LoggerService.logger.e('No file selected.');
    }

    setState(() {
      isUploading = false;
    });
  }

  Future<void> handleDeleteResource(String resourceId, String type) async {
    try {
      await deleteDocument(widget.eventId, resourceId);

      setState(() {
        if (type == 'document') {
          documents.removeWhere((doc) => doc['id'] == resourceId);
        } else if (type == 'image') {
          images.removeWhere((img) => img['id'] == resourceId);
        } else if (type == 'video') {
          videos.removeWhere((video) => video['id'] == resourceId);
        }
      });

      LoggerService.logger.i("Resource deleted successfully");
    } catch (e) {
      LoggerService.logger.e("Error deleting resource: $e");
    }
  }

  Widget buildSection({
    required String title,
    required List<Map<String, dynamic>> resources,
    required String uploadFolder,
    required String resourceType,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: () => handleFileUpload(uploadFolder, resourceType),
                  child: isUploading
                      ? const CircularProgressIndicator()
                      : const Text('Upload'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            resources.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: resources.length,
                    itemBuilder: (context, index) {
                      final resource = resources[index];
                      return ListTile(
                        leading: resource['contentType'] == 'image'
                            ? Image.network(
                                resource['url'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image_not_supported),
                              )
                            : const Icon(Icons.insert_drive_file),
                        title: Text(resource['fileName']),
                        subtitle: Text(formatFileSize(resource['size'])),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => handleDeleteResource(
                              resource['id'].toString(), resourceType),
                        ),
                        onTap: () {
                          if (resource['contentType'] == 'image') {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                content: Image.network(resource['url']),
                              ),
                            );
                          } else {
                            launchUrl(Uri.parse(resource['url']));
                          }
                        },
                      );
                    },
                  )
                : const Center(child: Text('No resources available.')),
          ],
        ),
      ),
    );
  }

  String formatFileSize(int sizeInBytes) {
    double sizeInMb = sizeInBytes / (1024 * 1024);
    final NumberFormat formatter = NumberFormat('#,##0.00');
    return "${formatter.format(sizeInMb)} MB";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Resources')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Manage your event resources',
                  style: TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              buildSection(
                title: 'Documents',
                resources: documents,
                uploadFolder: '/event_documents',
                resourceType: 'document',
              ),
              buildSection(
                title: 'Images',
                resources: images,
                uploadFolder: '/event_images',
                resourceType: 'image',
              ),
              buildSection(
                title: 'Videos',
                resources: videos,
                uploadFolder: '/event_videos',
                resourceType: 'video',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
