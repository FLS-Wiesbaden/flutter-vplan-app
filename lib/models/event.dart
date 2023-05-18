class Event {
  DateTime eventStart;
  DateTime eventEnd;
  String caption;
  int? id;
  String? type;
  bool noLesson = false;
  String? guid;

  Event({
    required this.eventStart, required this.eventEnd, required this.caption,
    this.noLesson = false, this.type, this.id, this.guid
  });

  bool matchDate(DateTime dt) {
    return dt.compareTo(eventStart) >= 0 && dt.compareTo(eventEnd) <= 0;
  }
  
  factory Event.fromJson(Map<String, dynamic> json) {
    
    return Event(
      eventStart: DateTime.parse(json['eventStart']),
      eventEnd: DateTime.parse(json['eventEnd']),
      caption: json['caption'],
      id: json['id'],
      type: json['type'],
      noLesson: json['noLesson'],
      guid: json['guid']
    );
  }

  Map<String, dynamic> toJson() => {
    'eventStart':eventStart.toIso8601String(),
    'eventEnd':eventEnd.toIso8601String(),
    'caption':caption,
    'id':id,
    'type':type,
    'noLesson':noLesson,
    'guid':guid
  };
}