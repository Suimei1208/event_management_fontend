import 'package:flutter/material.dart';

class EventAnalyticsPage extends StatelessWidget {
  const EventAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Analytics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            _buildStatistics(),
            const SizedBox(height: 20),
            _buildAttendanceRate(75, 25),
            // const SizedBox(height: 20),
            // _buildDemographics(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[200],
      ),
      child: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Summer Beach Party',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'July 15, 2023 • 2:00 PM',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text('Total Registrations', style: TextStyle(fontSize: 18)),
                    Text('248',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    Text('Check-ins', style: TextStyle(fontSize: 18)),
                    Text('186',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceRate(double attendance, double noShows) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[200],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Attendance Rate',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text('Attendance - $attendance%',
                        style: const TextStyle(color: Colors.blue)),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: 200,
                      child: Slider(
                        value: attendance,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        label: '75%',
                        onChanged: (value) {},
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text('No-shows - $noShows%',
                        style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: 200,
                      child: Slider(
                        value: noShows,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        label: '25%',
                        onChanged: (value) {},
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        // padding: const EdgeInsets.symmetric(vertical: 15.0),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: const Text('Download'),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        // padding: const EdgeInsets.symmetric(vertical: 15.0),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: const Text('Detail'),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildDemographics() {
  //   return const Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text('Demographics', style: TextStyle(fontSize: 18)),
  //       SizedBox(height: 10),
  //       Text('Age Groups', style: TextStyle(fontWeight: FontWeight.bold)),
  //       Text('18-24: 35%'),
  //       Text('25-34: 45%'),
  //       Text('35-44: 15%'),
  //       Text('45+: 5%'),
  //       SizedBox(height: 10),
  //       Text('Gender', style: TextStyle(fontWeight: FontWeight.bold)),
  //       Text('Male: 48%'),
  //       Text('Female: 51%'),
  //       Text('Other: 1%'),
  //     ],
  //   );
  // }
}
