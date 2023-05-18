import 'package:flutter/material.dart';
import 'package:de_fls_wiesbaden_vplan/models/bookmarkable.dart';

class SchoolType extends Bookmarkable {
  final int schoolTypeId;
  String name;

  SchoolType(this.schoolTypeId, this.name, bool bookmarked) {
    this.bookmarked = bookmarked;
  }

  Color getColor() {
    switch(schoolTypeId) {
      case 1: return const Color(0xFF8ADE5F);
      case 2: return const Color(0xFFF9D423);
      case 3: return const Color(0xFFFE9674);
      case 4: return const Color(0xFF29B6C7);
      case 5: return const Color(0xFF1CECD6);
    }
    return const Color.fromARGB(255, 134, 133, 133);
  }

  LinearGradient getGradient() {
    switch(schoolTypeId) {
      case 1: return const LinearGradient(colors: [Color(0xFFDDF855), Color(0xFF8ADE5F)]);
      case 2: return const LinearGradient(colors: [Color(0xFFF9D423), Color(0xFFF88200)]);
      case 3: return const LinearGradient(colors: [Color(0xFFFE9674), Color(0xFFFE395E)]);
      case 4: return const LinearGradient(colors: [Color(0xFF45E3F6), Color(0xFF1E8BF9)]);
      case 5: return const LinearGradient(colors: [Color(0xFF1CECD6), Color(0xFF09D778)]);
    }

    return const LinearGradient(colors: [Color(0xFFEFEFEF), Color(0xFFCFCFCF)]);
  }

  void setName(String name) => this.name = name;

  void merge(SchoolType e) {
    name = e.name;
  }
  
  factory SchoolType.fromJson(Map<String, dynamic> json) {
    return SchoolType(json['id'], json['name'], json['bookmarked'] ?? false);
  }

  Map<String, dynamic> toJson() => {
    'id': schoolTypeId,
    'name': name,
    'bookmarked': bookmarked
  };
}