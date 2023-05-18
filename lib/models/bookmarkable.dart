import 'package:flutter/material.dart';

class Bookmarkable extends ChangeNotifier {
  bool bookmarked = false;

  void setBookmarked(bool bookmarked) {
    this.bookmarked = bookmarked;
    notifyListeners();
  }
  void toggleBookmarked() => setBookmarked(!bookmarked);
  bool isBookmarked() => bookmarked;
}