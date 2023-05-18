import 'package:de_fls_wiesbaden_vplan/models/bookmarkable.dart';

class Teacher extends Bookmarkable implements Comparable {
  String firstName;
  String lastName;
  String shortcut;

  Teacher({
    required this.firstName,
    required this.lastName,
    required this.shortcut,
    bool bookmarked = false
  }) {
    this.bookmarked = bookmarked;
  }

  void merge(Teacher item) {
    firstName = item.firstName;
    lastName = item.lastName;
    shortcut = item.shortcut;
  }

  @override
  bool operator ==(Object other) {
    return other is Teacher && shortcut == other.shortcut;
  }

  @override
  int compareTo(other) {
    return listName.compareTo(other.listName);
  }

  String get displayName {
    if (lastName.isEmpty) {
      return shortcut;
    }
    return "${firstName.substring(0, 1)}. $lastName";
  }

  String get listName {
    if (lastName.isEmpty) {
      return shortcut;
    }
    return "$lastName, $firstName";
  }

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      firstName: json['firstName'] ?? json['firstname'] ?? '',
      lastName: json['lastName'] ?? json['lastname'] ?? '',
      shortcut: json['shortcut'],
      bookmarked: json['bookmarked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'shortcut': shortcut,
    'bookmarked': bookmarked
  };

  @override
  int get hashCode => shortcut.hashCode;
}
