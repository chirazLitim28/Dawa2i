import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../commons/colors.dart';

class TableCalendarWidget extends StatelessWidget {
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;

  const TableCalendarWidget(
      {Key? key, required this.selectedDay, required this.onDaySelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      child: Builder(
        builder: (context) => TableCalendar(
          focusedDay: DateTime.now(),
          firstDay: DateTime(2023, 1, 1),
          lastDay: DateTime(2050, 12, 31),
          calendarFormat: CalendarFormat.week,
          availableCalendarFormats: const {
            CalendarFormat.week: 'Week',
          },
          calendarStyle: CalendarStyle(
            outsideTextStyle: TextStyle(color: grey1Color),
            selectedDecoration: BoxDecoration(
              color: blue7Color,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: blue1Color,
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            formatButtonTextStyle: TextStyle().copyWith(
              color: white1Color,
              fontSize: 15.0,
            ),
            formatButtonDecoration: BoxDecoration(
              color: blue6Color,
              borderRadius: BorderRadius.circular(16.0),
            ),
            leftChevronIcon: Icon(Icons.chevron_left, color: blue1Color),
            rightChevronIcon: Icon(Icons.chevron_right, color: blue1Color),
          ),
          selectedDayPredicate: (DateTime date) {
            return isSameDay(selectedDay, date);
          },
          onDaySelected: (selectedDay, focusedDay) {
            onDaySelected(selectedDay, focusedDay);
          },
        ),
      ),
    );
  }
}
