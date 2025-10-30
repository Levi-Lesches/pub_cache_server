// Main file needs to print logs
// ignore_for_file: avoid_print

import "dart:io";

import "package:pub_cache_server/src/constants.dart";
import "package:shelf/shelf_io.dart" as shelf_io;
import "package:args/args.dart";

import "package:pub_cache_server/pub_cache_server.dart";

void main(List<String> args) async {
  final parser = ArgParser();
  parser.addOption(
    "cache",
    abbr: "c",
    help: "The path to your Pub cache. "
        "Can be omitted if the PUB_CACHE environment variable is set",
  );
  parser.addOption(
    "address",
    abbr: "a",
    defaultsTo: "127.0.0.1",
    help: "The address to host the server on",
  );
  parser.addOption(
    "port",
    abbr: "p",
    defaultsTo: "8000",
    help: "The port to host the server on",
  );
  parser.addOption(
    "domain",
    abbr: "d",
    defaultsTo: "pub.dev",
    help: "The domain of the online Pub server you use",
  );
  parser.addFlag(
    "help",
    abbr: "h",
    negatable: false,
    help: "Show this help message",
  );
  final results = parser.parse(args);
  if (results.flag("help")) {
    print(
      "\nUsage: pub_cache_server [--cache <cache-dir>] [--port <port>] [--address <address>]\n",
    );
    print(parser.usage);
    exit(0);
  }
  final portNumber = int.tryParse(results.option("port") ?? "");
  if (portNumber == null || portNumber < 0) {
    print("Port number must be a positive integer");
    exit(1);
  }
  final cacheEnv = Platform.environment["PUB_CACHE"];
  final resolvedCache = results.option("cache") ?? cacheEnv;
  if (resolvedCache == null) {
    print(
      "Error: If you omit --cache, you must define the PUB_CACHE environment variable",
    );
    exit(2);
  }
  Constants.init(
    pubCache: resolvedCache,
    host: results.option("address")!,
    port: portNumber,
    pubDomain: results.option("domain")!,
  );
  if (!Directory(Constants.pubCache).existsSync()) {
    print("Error: Could not find a Pub Cache at ${Constants.pubCache}");
    exit(3);
  }
  final router = getRouter();
  await shelf_io.serve(router.call, Constants.host, Constants.port);
  print("\nPub server started on ${Constants.host}:${Constants.port}");
  print("- Serving files from ${Constants.pubCache}\n");
}
