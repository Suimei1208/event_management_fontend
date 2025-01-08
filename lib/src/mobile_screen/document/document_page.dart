import 'package:event_management/src/service/drive_api.dart';
import 'package:event_management/src/service/logger_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class EventResourcesPage extends StatefulWidget {
  const EventResourcesPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EventResourcesPageState createState() => _EventResourcesPageState();
}

class _EventResourcesPageState extends State<EventResourcesPage> {
  List<Map<String, String>> documents = [
    {
      'title': 'Bài thuyết trình sự kiện.pptx',
      'date': 'Jun 15, 2023',
      'size': '2.5 MB'
    },
    {
      'title': 'Hướng dẫn sự kiện.pdf',
      'date': 'Jun 14, 2023',
      'size': '1.8 MB'
    },
  ];

  List<Map<String, String>> images = [
    {'title': 'Ảnh địa điểm 1', 'size': '2 MB'},
    {'title': 'Ảnh địa điểm 2', 'size': '3 MB'},
  ];

  List<Map<String, String>> videos = [
    {'title': 'Video quảng cáo sự kiện', 'duration': '2:30', 'size': '15 MB'},
  ];

  void addDocument(String title, String date, String size) {
    setState(() {
      documents.add({'title': title, 'date': date, 'size': size});
    });
  }

  void addImage(String title, String size) {
    setState(() {
      images.add({'title': title, 'size': size});
    });
  }

  void addVideo(String title, String duration, String size) {
    setState(() {
      videos.add({'title': title, 'duration': duration, 'size': size});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài Nguyên Sự Kiện'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quản lý tài liệu và tài nguyên của bạn',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tài Liệu Sự Kiện',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();

                  if (result != null) {
                    // Nếu người dùng chọn file, lấy đường dẫn file
                    String localFilePath = result.files.single.path!;

                    // Thực hiện tải lên Google Drive
                    authenticateAndUpload("test", localFilePath);
                  } else {
                    // Nếu không có file nào được chọn
                    LoggerService.logger.e('Không có file nào được chọn');
                  }
                },
                child: const Text('Tải Tài Liệu Mới'),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final doc = documents[index];
                  return DocumentItem(
                    title: doc['title']!,
                    date: doc['date']!,
                    size: doc['size']!,
                    onDelete: () {
                      setState(() {
                        documents.removeAt(index);
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Tài Nguyên Kỹ Thuật Số',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Thêm tài nguyên mới
                },
                child: const Text('Thêm Tài Nguyên'),
              ),
              const SizedBox(height: 10),
              const Text(
                'Video',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final video = videos[index];
                  return ResourceItem(
                    title: video['title']!,
                    duration: video['duration'],
                    size: video['size'],
                  );
                },
              ),
              const SizedBox(height: 10),
              const Text(
                'Hình Ảnh',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final img = images[index];
                  return ResourceItem(
                    title: img['title']!,
                    size: img['size'],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DocumentItem extends StatelessWidget {
  final String title;
  final String date;
  final String size;
  final VoidCallback onDelete;

  const DocumentItem(
      {super.key,
      required this.title,
      required this.date,
      required this.size,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text('Added $date • $size'),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: onDelete,
      ),
    );
  }
}

class ResourceItem extends StatelessWidget {
  final String title;
  final String? duration;
  final String? size;

  const ResourceItem(
      {super.key, required this.title, this.duration, this.size});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: duration != null ? Text('Duration: $duration') : null,
      trailing: size != null ? Text(size!) : null,
    );
  }
}
