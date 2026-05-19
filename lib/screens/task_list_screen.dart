import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';

class TaskListScreen extends StatefulWidget {
  final DateTime selectedDate;

  const TaskListScreen({super.key, required this.selectedDate});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _taskService = TaskService();
  final _authService = AuthService();

  static const Color kPurple = Color(0xFF7C3AED);
  static const Color kPurpleDark = Color(0xFF5B21B6);
  static const Color kAccent = Color(0xFFA78BFA);

  String get _userName =>
      _authService.currentUser?.name ?? 'Usuário';

  String get _formattedDate {
    final d = widget.selectedDate;
    return 'Dia ${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  List<TaskModel> get _tasks =>
      _taskService.getTasksForDate(widget.selectedDate);

  void _showAddDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Nova Tarefa',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: kPurpleDark,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: 'Nome da tarefa...',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kPurple),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kPurple, width: 2),
            ),
          ),
          onSubmitted: (_) => _addTask(controller.text, ctx),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar',
                style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => _addTask(controller.text, ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Adicionar',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _addTask(String title, BuildContext dialogCtx) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Digite o nome da tarefa!'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    Navigator.pop(dialogCtx);
    setState(() {
      _taskService.addTask(widget.selectedDate, trimmed);
    });
  }

  void _removeTask(String taskId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Remover Tarefa',
          style: TextStyle(fontWeight: FontWeight.w800, color: kPurpleDark),
        ),
        content: const Text('Deseja remover esta tarefa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar',
                style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _taskService.removeTask(widget.selectedDate, taskId);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Remover',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _toggleTask(String taskId) {
    setState(() {
      _taskService.toggleTask(widget.selectedDate, taskId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _tasks;
    final pendingCount = tasks.where((t) => !t.isCompleted).length;
    final doneCount = tasks.where((t) => t.isCompleted).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F0FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bem-vindo,',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          _userName[0].toUpperCase() +
                              _userName.substring(1) +
                              '!',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: kPurpleDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formattedDate,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: kPurple.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: kPurple, size: 22),
                    ),
                  ),
                ],
              ),
            ),

            // Stats row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _statChip(
                      Icons.pending_actions_rounded,
                      '$pendingCount pendente${pendingCount != 1 ? 's' : ''}',
                      Colors.orange.shade100,
                      Colors.orange.shade700),
                  const SizedBox(width: 10),
                  _statChip(
                      Icons.check_circle_rounded,
                      '$doneCount concluída${doneCount != 1 ? 's' : ''}',
                      Colors.green.shade100,
                      Colors.green.shade700),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Task list
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: kPurple,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: kPurple.withOpacity(0.35),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: tasks.isEmpty
                    ? _emptyState()
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Container(
                          color: Colors.white,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: tasks.length,
                            separatorBuilder: (_, __) => Divider(
                              color: Colors.grey.shade100,
                              height: 1,
                            ),
                            itemBuilder: (_, idx) {
                              final task = tasks[idx];
                              return _taskTile(task);
                            },
                          ),
                        ),
                      ),
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _showAddDialog,
                  icon: const Icon(Icons.add_rounded, size: 22),
                  label: const Text(
                    'Adicionar Tarefa',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 4,
                    shadowColor: kPurple.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // FAB
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF1E0B4B),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _taskTile(TaskModel task) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade50,
        child: Icon(Icons.delete_rounded, color: Colors.red.shade400),
      ),
      confirmDismiss: (_) async {
        _removeTask(task.id);
        return false; // Let the dialog handle it
      },
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        leading: GestureDetector(
          onTap: () => _toggleTask(task.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: task.isCompleted
                  ? Colors.green.shade500
                  : Colors.blue.shade400,
              boxShadow: [
                BoxShadow(
                  color: (task.isCompleted
                          ? Colors.green
                          : Colors.blue)
                      .withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              task.isCompleted
                  ? Icons.check_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: task.isCompleted
                ? Colors.grey.shade400
                : Colors.black87,
            decoration: task.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            decorationColor: Colors.grey.shade400,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mark complete toggle button
            IconButton(
              icon: Icon(
                task.isCompleted
                    ? Icons.undo_rounded
                    : Icons.check_circle_outline_rounded,
                color: task.isCompleted
                    ? Colors.orange.shade400
                    : Colors.green.shade500,
                size: 22,
              ),
              onPressed: () => _toggleTask(task.id),
              tooltip: task.isCompleted
                  ? 'Marcar como pendente'
                  : 'Marcar como concluída',
            ),
            // Delete button
            IconButton(
              icon:
                  Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 22),
              onPressed: () => _removeTask(task.id),
              tooltip: 'Remover tarefa',
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt_rounded,
              color: Colors.white.withOpacity(0.5), size: 64),
          const SizedBox(height: 16),
          Text(
            'Nenhuma tarefa ainda!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque em "Adicionar Tarefa"\npara começar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(
      IconData icon, String label, Color bg, Color fgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fgColor, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: fgColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
