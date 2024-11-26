/// Holds constants for the program.
class Constants {
  /// The path to the user's Pub cache.
  static late String pubCache;

  /// The IP address to host the server on.
  static String host = "127.0.0.1";

  /// The port to host to the server on.
  static int port = 8000;

  /// Initializes the constants.
  static void init({
    required String pubCache,
    String host = "127.0.0.1",
    int port = 8000,
  }) {
    Constants.pubCache = "$pubCache/hosted/pub.dev";
    Constants.host = host;
    Constants.port = port;
  }
}
