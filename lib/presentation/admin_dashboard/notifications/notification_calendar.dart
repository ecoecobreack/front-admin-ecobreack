import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class NotificationCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Map<DateTime, List<Map<String, dynamic>>> assignedPlans;
  final void Function(DateTime, DateTime) onDaySelected;
  final Widget Function(DateTime day, {bool isSelected, bool isToday})
  buildCalendarDay;
  final Widget planDetailsConsole;

  const NotificationCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.assignedPlans,
    required this.onDaySelected,
    required this.buildCalendarDay,
    required this.planDetailsConsole,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year + 1, now.month, now.day);

    return Card(
      child: Column(
        children: [
          Expanded(
            child: TableCalendar(
              firstDay: firstDay,
              lastDay: lastDay,
              focusedDay: focusedDay,
              selectedDayPredicate: (day) => isSameDay(selectedDay, day),
              onDaySelected: onDaySelected,
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  return buildCalendarDay(day);
                },
                selectedBuilder: (context, day, focusedDay) {
                  return buildCalendarDay(day, isSelected: true);
                },
                todayBuilder: (context, day, focusedDay) {
                  return buildCalendarDay(day, isToday: true);
                },
              ),
              calendarStyle: const CalendarStyle(
                outsideDaysVisible: false,
                cellMargin: EdgeInsets.all(4),
                cellPadding: EdgeInsets.all(0),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(child: SingleChildScrollView(child: planDetailsConsole)),
        ],
      ),
    );
  }
}
