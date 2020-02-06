import 'package:ete_progress/day.dart';

import 'package:yaml/yaml.dart';

class Calendar {
  final int year;

  final Day start;
  final Day end;

  final List<Day> whitelist;
  final List<Day> blacklist;

  Calendar({this.year, this.start, this.end, this.whitelist, this.blacklist});

  factory Calendar.from(String content, [int year]) {
    final YamlMap yaml = loadYaml(content);
    if (!yaml.containsKey('start') || !yaml.containsKey('end')) throw new FormatException('Missing start and end day');

    final start = dayRegex.firstMatch(yaml['start']);
    final end = dayRegex.firstMatch(yaml['end']);
    final whitelist = (yaml['whitelist'] as YamlList).expand((day) {
      final match = dayRegex.firstMatch(day);
      return match.group(3) == null ? [Day.fromMatch(match)] : DayInterval.fromMatch(match).toDayList();
    }).toList(growable: false);
    final blacklist = (yaml['blacklist'] as YamlList).expand((day) {
      final match = dayRegex.firstMatch(day);
      return match.group(3) == null ? [Day.fromMatch(match)] : DayInterval.fromMatch(match).toDayList();
    }).toList(growable: false);

    return Calendar(
      year: year ?? DateTime.now().year,
      start: Day.fromMatch(start),
      end: Day.fromMatch(end),
      whitelist: whitelist,
      blacklist: blacklist,
    );
  }

  bool isSchoolDay(Day day) =>
      day >= start && day <= end && day.isWeekDay ? !blacklist.contains(day) : whitelist.contains(day);

  int getSchoolDays([Day untilDay]) {
    int days = 0;
    Day day = start;
    while (day <= end) {
      if (isSchoolDay(day)) days++;
      day++;
      if (untilDay != null && day > untilDay) break;
    }
    return days;
  }
}
