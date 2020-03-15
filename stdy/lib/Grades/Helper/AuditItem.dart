import 'Course.dart';
class AuditItem {
  AuditItem({
    this.expandedValue,
    this.headerValue,
    this.expandedText,
    this.isExpanded = false,
    this.semGPA
  });

  String expandedValue;
  String headerValue;
  List<Course> expandedText;
  bool isExpanded;
  String semGPA;
}