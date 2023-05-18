class Subject implements Comparable {
  String name;
  String shortcut;

  Subject({
    required this.name,
    required this.shortcut,
  });

  void merge(Subject item) {
    name = item.name;
    shortcut = item.shortcut;
  }

  @override
  bool operator ==(Object other) {
    return other is Subject && shortcut == other.shortcut;
  }

  @override
  int compareTo(other) {
    return name.compareTo(other.name);
  }

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      name: json['name'],
      shortcut: json['shortcut'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'shortcut': shortcut,
  };
  
  @override
  int get hashCode => shortcut.hashCode;
  
}
