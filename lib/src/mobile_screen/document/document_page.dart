// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';
import 'package:event_management/src/service/document_service.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class EventResourcesPage extends StatefulWidget {
  final int eventId;

  const EventResourcesPage({super.key, required this.eventId});

  @override
  _EventResourcesPageState createState() => _EventResourcesPageState();
}

class _EventResourcesPageState extends State<EventResourcesPage> {
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

    FilePickerResult? result;

    if (type == 'image') {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );
    } else if (type == 'video') {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4'],
      );
    } else if (type == 'document') {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'pdf', 'pptx'],
      );
    }

    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      int sizeInBytes = file.lengthSync();

      if (type == 'image' && sizeInBytes > 4 * 1024 * 1024) {
        LoggerService.logger.e('Image size exceeds 4MB.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image size must not exceed 4MB.')),
        );
        setState(() {
          isUploading = false;
        });
        return;
      } else if (type == 'video' && sizeInBytes > 50 * 1024 * 1024) {
        LoggerService.logger.e('Video size exceeds 50MB.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video size must not exceed 50MB.')),
        );
        setState(() {
          isUploading = false;
        });
        return;
      }

      String contentType = '';
      if (type == 'document') {
        contentType = 'document';
      } else if (type == 'image') {
        contentType = 'image';
      } else if (type == 'video') {
        contentType = 'video';
      }

      try {
        String fileUrl = await uploadFileToImageKit(file, folder, fileName);

        await uploadDocument(
            widget.eventId, fileName, fileUrl, contentType, sizeInBytes);

        fetchResources();

        LoggerService.logger
            .i("File added successfully: $fileName, size: $sizeInBytes bytes");
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => handleFileUpload(uploadFolder, resourceType),
          child: isUploading
              ? const CircularProgressIndicator()
              : Text('Thêm $title'),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: resources.length,
          itemBuilder: (context, index) {
            final resource = resources[index];
            return ListTile(
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
                } else if (resource['contentType'] == 'video') {
                  launchUrl(Uri.parse(resource['url']));
                } else if (resource['contentType'] == 'document') {
                  launchUrl(Uri.parse(resource['url']));
                }
              },
            );
          },
        ),
      ],
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
      appBar: AppBar(title: const Text('Tài Nguyên Sự Kiện')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Quản lý tài liệu và tài nguyên của bạn',
                  style: TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              buildSection(
                title: 'Tài Liệu Sự Kiện',
                resources: documents,
                uploadFolder: '/event_documents',
                resourceType: 'document',
              ),
              const SizedBox(height: 20),
              buildSection(
                title: 'Hình Ảnh',
                resources: images,
                uploadFolder: '/event_images',
                resourceType: 'image',
              ),
              const SizedBox(height: 20),
              buildSection(
                title: 'Video',
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
