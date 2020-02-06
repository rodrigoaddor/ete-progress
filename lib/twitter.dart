import 'dart:convert';

import 'package:dotenv/dotenv.dart' show env;
import 'package:http/http.dart' show Response;
import 'package:twitter_api/twitter_api.dart';

final twitter = twitterApi(
  consumerKey: env['TWITTER_CONSUMER_KEY'],
  consumerSecret: env['TWITTER_CONSUMER_SECRET'],
  token: env['TWITTER_TOKEN_KEY'],
  tokenSecret: env['TWITTER_TOKEN_SECRET'],
);

Future<double> getLastPercent() async {
  final Response res = await twitter.getTwitterRequest('GET', 'statuses/user_timeline.json');
  if (res.statusCode ~/ 100 != 2) throw FormatException('Status code ${res.statusCode} from Twitter API');
  final String lastTweet = jsonDecode(res.body)[0]['text'];
  return int.parse(lastTweet.split('%')[0]) / 100;
}

Future<bool> postTweet(String text) async {
  final Response res = await twitter.getTwitterRequest('POST', 'statuses/update.json', options: {'status': text});
  return res.statusCode ~/ 100 != 2;
}
