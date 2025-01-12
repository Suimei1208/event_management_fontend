import 'package:event_management/src/service/event_service.dart';
import 'package:flutter/material.dart';

class EventReviewPageWeb extends StatefulWidget {
  final int eventId;
  const EventReviewPageWeb({
    super.key,
    required this.eventId,
  });
  static const routeName = "/rate-event";
  @override
  // ignore: library_private_types_in_public_api
  _EventReviewPageWebState createState() => _EventReviewPageWebState();
}

class _EventReviewPageWebState extends State<EventReviewPageWeb> {
  int _rating = 0;
  bool _recommend = false;
  final TextEditingController _textController1 = TextEditingController();

  void _submitReview() async {
    await addReview(widget.eventId, _textController1.text, _rating);
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Review'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Rate Your Experience',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      size: 50,
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.yellow,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 20),
              const Text(
                'Write Your Review (Optional)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Share your thoughts about the event...',
                  border: OutlineInputBorder(),
                ),
                controller: _textController1,
              ),
              const SizedBox(height: 20),
              const Text(
                'Would you recommend this event?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.thumb_up,
                      color: _recommend ? Colors.blue : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _recommend = true;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.thumb_down,
                      color: !_recommend ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _recommend = false;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 30.0,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('Submit Review'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
