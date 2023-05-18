import 'package:de_fls_wiesbaden_vplan/models/bookmarkable.dart';

class SchoolClass extends Bookmarkable {
  int schoolType;
  String name;

  SchoolClass(this.schoolType, this.name, bookmarked) {
    this.bookmarked = bookmarked;
  }

  void merge(SchoolClass e) {
    schoolType = e.schoolType;
    name = e.name;
  }

  factory SchoolClass.fromJson(Map<String, dynamic> json) {
    return SchoolClass(
      json['schoolType'],
      json['name'],
      json['bookmarked'] ?? false
    );
  }

  factory SchoolClass.fromUpstreamJson(Map<String, dynamic> json) {
    return SchoolClass(
      json['schoolType'],
      json['shortcut'],
      json['bookmarked'] ?? false
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'schoolType': schoolType,
    'bookmarked': bookmarked
  };
}