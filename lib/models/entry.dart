import 'package:intl/intl.dart';
import 'package:de_fls_wiesbaden_vplan/models/lesson.dart';
import 'package:de_fls_wiesbaden_vplan/models/schoolclass.dart';
import 'package:de_fls_wiesbaden_vplan/models/subject.dart';
import 'package:de_fls_wiesbaden_vplan/models/teacher.dart';

class Entry implements Comparable {
  // Base data
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String hourText;
  final String className;
  final int school;
  final int entryType;

  // Original data
  final Teacher? teacher; // Yes, can be null. Really. 
  final Subject subject;
  final String? room;

  // Change data
  final Teacher? chgTeacher;
  final Subject? chgSubject;
  final String? chgRoom;

  // Additional data
  final String? info;
  final String? note;

  // for comparism
  final String cmphash;

  Entry(
      {required this.startDateTime,
      required this.endDateTime,
      required this.hourText,
      required this.className,
      required this.school,
      required this.entryType,
      required this.teacher,
      required this.subject,
      this.room,
      this.chgTeacher,
      this.chgSubject,
      this.chgRoom,
      this.info,
      this.note,
      required this.cmphash});

  String getShortDateString() {
    final DateFormat formatter = DateFormat('dd.MM.');
    final String dateString = "${formatter.format(startDateTime)}, ";
    final DateTime now = DateTime.now();
    final bool isToday = startDateTime.year == now.year && startDateTime.month == now.month && startDateTime.day == now.day;
    return '${isToday ? "" : dateString}$hourText';
  }

  String getStartTime() {
    final DateFormat formatter = DateFormat('HH:mm');
    return formatter.format(startDateTime);
  }
  String getEndTime() {
    final DateFormat formatter = DateFormat('HH:mm');
    return formatter.format(endDateTime);
  }

  bool isFree() {
    return (entryType & 64) == 64;
  }

  bool isRegular() {
    return (entryType & 2048) == 2048;
  }

  bool isYardDuty() {
    return (entryType & 128) == 128;
  }

  String? get chgNotes {
    if (info == null && note == null) {
      return null;
    }

    String delim = info != null && note != null ? " - " : "";
    return "${info ?? ''}$delim${note ?? ''}";
  }

  Lesson? getLessonOfEntry() {
    return teacher == null ? null : Lesson(className, subject, teacher!, false);
  }

  @override
  int compareTo(other) {
    if (startDateTime.isAfter(other.startDateTime)) {
      return 1;
    } else if (startDateTime.isBefore(other.startDateTime)) {
      return -1;
    } else if (school < other.school) {
      return -1;
    } else if (school > other.school) {
      return 1;
    } else {
      return className.compareTo(other.className);
    }    
  }

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      startDateTime: DateTime.parse(json['startDateTime']),
      endDateTime: DateTime.parse(json['endDateTime']),
      hourText: json['hourtext'],
      className: json['class'],
      school: json['school'],
      entryType: json['type'],
      teacher: json['orig']['teacher'] != null && json['orig']['teacher']['shortcut'] != null ? 
                Teacher.fromJson(json['orig']['teacher'] as Map<String, dynamic>) : null,
      subject: Subject.fromJson(json['orig']['subject'] as Map<String, dynamic>),
      room: json['orig']['room'],
      chgTeacher: json['diff']['teacher'] != null ? Teacher.fromJson(json['diff']['teacher']) :  null,
      chgSubject: json['diff']['subject'] != null ? Subject.fromJson(json['diff']['subject']) : null,
      chgRoom: json['diff']['room'],
      info: json['info'],
      note: json['note'],
      cmphash: json['cmphash']
    );
  }

  Map<String, dynamic> toJson() => {
    'startDateTime': startDateTime.toIso8601String(),
    'endDateTime': endDateTime.toIso8601String(),
    'hourtext': hourText,
    'class': className,
    'school': school,
    'type': entryType,
    'orig': {
      'teacher': teacher?.toJson(),
      'subject': subject.toJson(),
      'room': room,
    },
    'diff': {
      'teacher': chgTeacher?.toJson(),
      'subject': chgSubject?.toJson(),
      'room': chgRoom,
    },
    'info': info,
    'note': note,
    'cmphash': cmphash
  };

  match(Iterable<SchoolClass> bookmarked) {
    for(var sc in bookmarked) {
      if (sc.name == className && sc.schoolType == school) {
        return true;
      }
    }
    return false;
  }
}
