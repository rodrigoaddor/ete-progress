import 'package:equatable/equatable.dart';

final dayRegex = RegExp(r'(\d{1,2})\/(\d{1,2})(?:-(\d{1,2}))?');

class Day extends Equatable {
  final int year;
  final int month;
  final int day;

  const Day(this.year, this.month, this.day);

  factory Day.fromMatch(Match match, [int year]) {
    if (match.group(3) != null)
      throw FormatException('Invalid group count (${match.groupCount}) in string ${match.input}');
    return Day(year ?? DateTime.now().year, int.parse(match.group(1)), int.parse(match.group(2)));
  }

  factory Day.fromDateTime(DateTime dateTime) => Day(dateTime.year, dateTime.month, dateTime.day);
  factory Day.now() => Day.fromDateTime(DateTime.now());

  DateTime get asDateTime => DateTime(this.year, this.month, this.day);
  bool get isWeekDay => asDateTime.weekday != DateTime.saturday && asDateTime.weekday != DateTime.sunday;

  Day operator +(int value) => Day.fromDateTime(this.asDateTime.add(Duration(days: value)));
  bool operator >(Day other) => asDateTime.isAfter(other.asDateTime);
  bool operator >=(Day other) => asDateTime.isAfter(other.asDateTime) || this == other;
  bool operator <(Day other) => asDateTime.isBefore(other.asDateTime);
  bool operator <=(Day other) => asDateTime.isBefore(other.asDateTime) || this == other;

  @override
  List<Object> get props => [this.month, this.day];

  @override
  String toString() => '$month/$day';
}

class DayInterval {
  final int year;
  final int month;
  final int dayStart;
  final int dayEnd;

  const DayInterval(this.year, this.month, this.dayStart, this.dayEnd);

  factory DayInterval.fromMatch(Match match, [int year]) {
    if (match.group(3) == null) throw FormatException('Invalid group count: ${match.groupCount}');
    return DayInterval(
      year ?? DateTime.now().year,
      int.parse(match.group(1)),
      int.parse(match.group(2)),
      int.parse(match.group(3)),
    );
  }

  List<Day> toDayList() {
    final List<Day> days = List(this.dayEnd - this.dayStart + 1);
    for (int i = 0; i <= this.dayEnd - this.dayStart; i++) days[i] = Day(this.year, this.month, this.dayStart + i);
    return days;
  }
}
