// ignore_for_file: file_names

import 'package:flutter/material.dart';

class CheckInData extends ChangeNotifier {
  List<Map<String, dynamic>> _attendanceData = [];

  List<Map<String, dynamic>> get attendanceData => _attendanceData;

  void setAttendanceData(List<Map<String, dynamic>> newData) {
    _attendanceData = newData;
    notifyListeners(); // Notify listeners to update their UI
  }
}
