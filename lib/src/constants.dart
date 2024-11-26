/// Holds constants for the program.
class Constants {
  /// The path to the user's Pub cache. Defaults to the `PUB_CACHE` environment variable.
  static late String pubCache;

  /// The IP address to host the server on. Defaults to `127.0.0.1`.
  static late String host;

  /// The port to host to the server on. Defaults to `8000`.
  static late int port;

  /// Which online Pub server to choose from. Defaults to `pub.dev`.
  static late String pubDomain;

  /// Initializes the constants.
  static void init({
    required String pubCache,
    required String host,
    required int port,
    required String pubDomain,
  }) {
    Constants.host = host;
    Constants.port = port;
    Constants.pubDomain = pubDomain;
    Constants.pubCache = "$pubCache/hosted/$pubDomain";
  }
}
