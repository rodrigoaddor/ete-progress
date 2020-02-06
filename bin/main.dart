import 'package:ete_progress/calendar.dart';
import 'package:ete_progress/day.dart';
import 'package:ete_progress/find_file.dart';
import 'package:ete_progress/progress_bar.dart';

import 'package:dotenv/dotenv.dart' show load, env;

List<String> getFilePaths(int year) {
  return [
    '$year.yaml',
    'data/$year.yaml',
  ];
}

void main() async {
  load();
  int year = int.tryParse(env['YEAR']) ?? DateTime.now().year;
  print('Using $year as current year.');

  final file = await findFile(getFilePaths(year)..add(env['DATA_PATH']));
  if (file != null)
    print('Using ${file.path} as data file');
  else
    print('Couldn\'t find data file.');

  final calendar = Calendar.from(await file.readAsString(), year);
  final totalDays = calendar.getSchoolDays();
  final today = calendar.getSchoolDays(Day.fromDateTime(DateTime.now()));
  final percent = today / totalDays;

  print('${(percent * 100).floor()}%    ${generateProgressBar(percent)}\n'
      'Faltam ${calendar.end.asDateTime.difference(Day.now().asDateTime).inDays} dias');
}
