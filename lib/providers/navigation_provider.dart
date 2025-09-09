import 'package:flutter/material.dart';
import 'package:isdb_radio/pages/archive_list_page.dart';
import 'package:isdb_radio/pages/radio_streaming_page.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;


  final List<Widget> _pages = [
    RadioStreamingPage(),
    ArchiveListPage(),
  ];

  int get currentIndex => _currentIndex;
  List<Widget> get pages => _pages;
  Widget get currentPage => _pages[_currentIndex];

  void setCurrentIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void goToLive() {
    setCurrentIndex(0);
  }

  void goToArchive() {
    setCurrentIndex(1);
  }
}