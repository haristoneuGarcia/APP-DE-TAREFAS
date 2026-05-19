class TaskModel {
  final String id;
  String title;
  bool isCompleted;
  final DateTime date;

  TaskModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.date,
  });
}
