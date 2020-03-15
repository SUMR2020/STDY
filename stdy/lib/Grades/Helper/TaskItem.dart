import '../../Schedule/Helper/Task.dart';
class TaskItem {
  TaskItem({
    this.expandedValue,
    this.headerValue,
    this.expandedText,
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  List<Task> expandedText;
  bool isExpanded;
}