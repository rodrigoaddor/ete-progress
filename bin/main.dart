import 'dart:convert';

import 'package:ete_progress/calendar.dart';
import 'package:ete_progress/day.dart';
import 'package:ete_progress/find_file.dart';
import 'package:ete_progress/progress_bar.dart';
import 'package:ete_progress/server.dart';

import 'package:args/args.dart';
import 'package:dotenv/dotenv.dart' show env, load;
import 'package:ete_progress/twitter.dart';

List<String> getFilePaths(int year) => [
      '$year.yaml',
      'data/$year.yaml',
    ];

void doServer(Calendar calendar) async {
  final totalSchoolDays = calendar.getSchoolDays();

  final server = Server()..listen(int.tryParse(env['PORT']));

  server.get('/percent', (request) {
    final today = calendar.getSchoolDays(Day.now());
    request.response.write(json.encode({'percent': today / totalSchoolDays}));
  });

  server.get('/', (request) {
    final schoolDay = calendar.getSchoolDays(Day.now());

    request.response.write(json.encode({
      'percent': schoolDay / totalSchoolDays,
      'schoolDay': schoolDay,
      'remainSchoolDays': totalSchoolDays - schoolDay,
      'remainDays': calendar.end.asDateTime.difference(Day.now().asDateTime).inDays,
      'totalSchoolDays': totalSchoolDays,
    }));
  });
}

void doTweet(Calendar calendar) async {
  final totalDays = calendar.getSchoolDays();
  final today = calendar.getSchoolDays(Day.fromDateTime(DateTime.now()));
  final percent = today / totalDays;

  final msg = ('${(percent * 100).floor()}%    ${generateProgressBar(percent)}\n'
      'Faltam ${calendar.end.asDateTime.difference(Day.now().asDateTime).inDays} dias');

  if (await getLastPercent() < (percent * 100).toInt() / 100) {
    print('Tweeting:\n$msg');
    postTweet(msg);
  } else {
    print('Tweet for ${(percent * 100).floor()}% already exists.');
  }
}

void main(List<String> args) async {
  final parser = ArgParser();
  parser.addFlag('tweet-only', abbr: 't');
  final tweetOnly = parser.parse(args)['tweet-only'];

  load();
  final year = int.tryParse(env['YEAR'] ?? '') ?? DateTime.now().year;
  print('Using $year as current year.');

  final file = await findFile(getFilePaths(year)..add(env['DATA_PATH']));
  if (file != null)
    print('Using ${file.path} as data file');
  else
    print('Couldn\'t find data file.');

  final calendar = Calendar.from(await file.readAsString(), year);

  if (tweetOnly) {
    doTweet(calendar);
  } else {
    doServer(calendar);
  }
}
