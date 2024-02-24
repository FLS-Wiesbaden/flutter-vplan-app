import 'package:flutter/material.dart';

class Bookmarkable extends ChangeNotifier {
  bool bookmarked = false;

  void setBookmarked(bool bookmarked, {bool skipNotification = false}) {
    this.bookmarked = bookmarked;
    if (!skipNotification) {
      notifyListeners();
    }
  }
  void toggleBookmarked() => setBookmarked(!bookmarked);
  bool isBookmarked() => bookmarked;
}