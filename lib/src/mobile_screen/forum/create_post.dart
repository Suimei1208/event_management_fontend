import 'package:event_management/src/service/forum_service.dart';
import 'package:event_management/widget/dialog_widget.dart';
import 'package:flutter/material.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  String? selectedCategory;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _handlePost() {
    if (selectedCategory == null || selectedCategory!.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const DialogWidget(
            message: 'Vui lòng chọn category trước khi đăng bài',
            title: 'Notification',
          );
        },
      );
    } else {
      createPost(
        _titleController.text,
        _descriptionController.text,
        selectedCategory!,
        'https://stickershop.line-scdn.net/stickershop/v1/product/25567097/LINEStorePC/main.png?v=1',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Post Title',
                border: OutlineInputBorder(),
              ),
              controller: _titleController,
            ),
            const SizedBox(height: 16.0),
            TextField(
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Share your thoughts...',
                border: OutlineInputBorder(),
              ),
              controller: _descriptionController,
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 10.0,
              children: [
                _buildCategoryChip('General Discussion'),
                _buildCategoryChip('Questions'),
                _buildCategoryChip('Tips & Tricks'),
                _buildCategoryChip('Feedback'),
              ],
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Attachments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.add_a_photo),
                  onPressed: () {
                    // Add photo action
                  },
                ),
                const Text('Add Photos'),
              ],
            ),
            const SizedBox(height: 16.0),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _handlePost();
                  },
                  child: const Text('Post'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    return ChoiceChip(
      label: Text(label),
      selected: selectedCategory == label,
      onSelected: (bool selected) {
        setState(() {
          selectedCategory = selected ? label : null;
        });
      },
    );
  }
}
