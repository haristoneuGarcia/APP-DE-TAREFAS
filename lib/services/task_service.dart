import '../models/task_model.dart';

class TaskService {
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal();

  final Map<String, List<TaskModel>> _tasksByDate = {};

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  List<TaskModel> getTasksForDate(DateTime date) {
    final key = _dateKey(date);
    final tasks = _tasksByDate[key] ?? [];

    // Pendentes primeiro (ordem alfabética), depois concluídas (ordem alfabética)
    final pending = tasks.where((t) => !t.isCompleted).toList()
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    final completed = tasks.where((t) => t.isCompleted).toList()
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

    return [...pending, ...completed];
  }

  void addTask(DateTime date, String title) {
    final key = _dateKey(date);
    _tasksByDate.putIfAbsent(key, () => []);
    _tasksByDate[key]!.add(TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      date: date,
    ));
  }

  void removeTask(DateTime date, String taskId) {
    final key = _dateKey(date);
    _tasksByDate[key]?.removeWhere((t) => t.id == taskId);
  }

  void toggleTask(DateTime date, String taskId) {
    final key = _dateKey(date);
    final tasks = _tasksByDate[key];
    if (tasks != null) {
      for (var t in tasks) {
        if (t.id == taskId) {
          t.isCompleted = !t.isCompleted;
          break;
        }
      }
    }
  }

  bool hasTasksForDate(DateTime date) {
    final key = _dateKey(date);
    return (_tasksByDate[key] ?? []).isNotEmpty;
  }
}
