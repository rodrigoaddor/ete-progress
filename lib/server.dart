import 'dart:io';

class Server {
  Map<String, Function(HttpRequest)> _handlers = {};

  void listen([int port = 80]) async {
    print('Server listening on port $port.');
    final server = await HttpServer.bind(InternetAddress.anyIPv4, port);

    await for (final HttpRequest request in server) {
      print(request.uri.path);
      if (this._handlers.containsKey(request.uri.path)) {
        this._handlers[request.uri.path](request);
      } else {
        notFound(request);
      }
      await request.response.close();
    }
  }

  void get(String uri, Function(HttpRequest) handler) {
    if (!uri.startsWith('/')) uri = '/$uri';
    this._handlers[uri] = handler;
  }

  void notFound(HttpRequest request) {
    request.response.statusCode = HttpStatus.notFound;
    request.response.write('Not Found');
  }
}
