import 'package:de_fls_wiesbaden_vplan/models/bookmarkable.dart';
import 'package:de_fls_wiesbaden_vplan/models/entry.dart';
import 'package:de_fls_wiesbaden_vplan/models/subject.dart';
import 'package:de_fls_wiesbaden_vplan/models/teacher.dart';

class Lesson extends Bookmarkable implements Comparable {
  String name;
  Subject subject;
  Teacher teacher;

  Lesson(this.name, this.subject, this.teacher, bool bookmarked) {
    this.bookmarked = bookmarked;
  }

  @override
  bool operator ==(Object other) {
    return other is Lesson && name == other.name && subject == other.subject && teacher == other.teacher;
  }
  
  @override
  int compareTo(other) {
    if (name.compareTo(other.name) != 0) {
      return name.compareTo(other.name);
    } else if (subject.compareTo(other.subject) != 0) {
      return subject.compareTo(other.subject);
    } else if (teacher.compareTo(other.teacher) != 0) {
      return teacher.compareTo(other.teacher);
    } else {
      return 0;
    }
  }

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      json['name'],
      Subject.fromJson(json['subject']),
      Teacher.fromJson(json['teacher']),
      json['bookmarked'] ?? false
    );
  }

  factory Lesson.fromEntry(Entry entry) {
    return Lesson(entry.className, entry.subject, entry.teacher!, false);
  }

  static getHashOfEntry(Entry entry) {
    return entry.className.hashCode*-5*entry.subject.hashCode*-6*(entry.teacher != null ? entry.teacher!.hashCode : -9999);
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'subject': subject.toJson(),
    'teacher': teacher.toJson(),
    'bookmarked': bookmarked
  };

  @override
  int get hashCode => name.hashCode*-5*subject.hashCode*-6*teacher.hashCode;

  String getText() {
    return "$name hat ${subject.name} bei ${teacher.displayName}";
  }
}