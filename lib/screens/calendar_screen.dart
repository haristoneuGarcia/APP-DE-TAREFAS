import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';
import 'login_screen.dart';
import 'task_list_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDay;
  final _taskService = TaskService();
  final _authService = AuthService();

  static const Color kPurple = Color(0xFF7C3AED);
  static const Color kPurpleDark = Color(0xFF5B21B6);
  static const Color kAccent = Color(0xFFA78BFA);

  String get _userName =>
      _authService.currentUser?.name ?? 'Usuário';

  List<DateTime> get _daysInMonth {
    final first = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final last = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final days = <DateTime>[];
    for (int i = 1; i <= last.day; i++) {
      days.add(DateTime(_focusedMonth.year, _focusedMonth.month, i));
    }
    return days;
  }

  int get _firstWeekday {
    final first = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    return first.weekday % 7; // 0=Sun
  }

  void _prevMonth() {
    setState(() {
      _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  void _selectDay(DateTime day) {
    setState(() => _selectedDay = day);
  }

  void _goToTasks() {
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecione um dia primeiro!'),
          backgroundColor: kPurple,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (_) => TaskListScreen(selectedDate: _selectedDay!),
    ))
        .then((_) => setState(() {}));
  }

  void _logout() {
    _authService.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  static const List<String> _weekLabels = [
    'Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'
  ];

  static const List<String> _monthNames = [
    '', 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isToday(DateTime d) => _isSameDay(d, DateTime.now());

  @override
  Widget build(BuildContext context) {
    final days = _daysInMonth;
    final startOffset = _firstWeekday;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F0FF),
      body: SafeArea(
        child: Column(
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
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _logout,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: kPurple.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.logout_rounded,
                          color: kPurple, size: 22),
                    ),
                  ),
                ],
              ),
            ),

            // Calendar card
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Month nav
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: _prevMonth,
                            icon: const Icon(Icons.chevron_left,
                                color: Colors.white),
                          ),
                          Text(
                            '${_monthNames[_focusedMonth.month]} ${_focusedMonth.year}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          IconButton(
                            onPressed: _nextMonth,
                            icon: const Icon(Icons.chevron_right,
                                color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Week headers
                      Row(
                        children: _weekLabels
                            .map(
                              (d) => Expanded(
                                child: Center(
                                  child: Text(
                                    d,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 8),

                      // Days grid
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            childAspectRatio: 1,
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4,
                          ),
                          itemCount: startOffset + days.length,
                          itemBuilder: (_, idx) {
                            if (idx < startOffset) return const SizedBox();
                            final day = days[idx - startOffset];
                            final isSelected = _selectedDay != null &&
                                _isSameDay(day, _selectedDay!);
                            final isToday = _isToday(day);
                            final hasTasks =
                                _taskService.hasTasksForDate(day);

                            return GestureDetector(
                              onTap: () => _selectDay(day),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? kPurple
                                      : isToday
                                          ? kAccent.withOpacity(0.25)
                                          : null,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${day.day}',
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : isToday
                                                ? kPurpleDark
                                                : Colors.black87,
                                        fontWeight: isSelected || isToday
                                            ? FontWeight.w700
                                            : FontWeight.normal,
                                        fontSize: 13,
                                      ),
                                    ),
                                    if (hasTasks)
                                      Container(
                                        width: 5,
                                        height: 5,
                                        margin: const EdgeInsets.only(top: 2),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.white
                                              : kPurple,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Select button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _goToTasks,
                          icon: const Icon(Icons.calendar_today_rounded,
                              size: 18),
                          label: Text(
                            _selectedDay != null
                                ? 'Ver tarefas de ${_selectedDay!.day}/${_selectedDay!.month}'
                                : 'Selecionar o dia',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E0B4B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
