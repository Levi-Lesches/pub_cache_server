// ignore_for_file: parameter_assignments

import "dart:convert";
import "dart:io";

import "package:shelf/shelf.dart";
import "package:shelf_router/shelf_router.dart";

import "constants.dart";
import "tar.dart";

extension on Directory {
  String operator /(String other) => "$path/$other";
}

/// Represents a standard JSON object
typedef Json = Map<String, dynamic>;

/// Fixes a URL to point to this host and port instead of the real Pub.
String fixupUrl(String url) => Uri.parse(url).replace(
  scheme: "http",
  host: Constants.host,
  port: Constants.port,
).toString();

/// Returns the given JSON as an HTTP 200 OK response.
Response okJson(Json json) => Response.ok(jsonEncode(json));

/// Returns the security advisories, which are all blank.
Response getAdvisories(Request request) => okJson({
  "advisories": const <void>[],
  "advisoriesUpdated": DateTime.now().toIso8601String(),
});

/// Gets info about all the versions of a given package.
///
/// This function:
/// - looks for the cache file in the user's [Constants.pubCache]
/// - changes all URLs to point to the server using [fixupUrl]
/// - removes all integrity checks so Pub doesn't complain
/// - returns the remaining data as-is
Response getVersions(Request request, String package) {
  final cache = File("${Constants.pubCache}/.cache/$package-versions.json");
  if (!cache.existsSync()) return Response.notFound("This server does not have any versions of $package");
  final versionContents = cache.readAsStringSync();
  final versionData = jsonDecode(versionContents) as Json;
  for (final version in versionData["versions"]) {
    version["archive_url"] = fixupUrl(version["archive_url"]);
    version["archive_sha256"] = null;
  }
  return okJson(versionData);
}

/// Returns the given package at the given version as a compressed tarball (`.tar.gz` file)
///
/// This function:
/// - Finds the package and version in the user's Pub cache, or returns an HTTP 404
/// - If the tarball does not exist, make it using [makeTarball] and cache it
/// - Return the tarball as-is
Future<Response> getTarball(Request request, String package, String version) async {
  package = Uri.decodeFull(package);
  version = Uri.decodeFull(version);
  final packageDir = Directory("${Constants.pubCache}\\$package-$version");
  if (!packageDir.existsSync()) {
    return Response.notFound("This server does not have version $version of $package");
  }
  final tarballsDir = Directory("${Constants.pubCache}/.tarballs");
  tarballsDir.createSync();
  final output = File(tarballsDir / "$package-$version.tar.gz");
  if (!output.existsSync()) await makeTarball(packageDir, output);
  return Response.ok(output.openRead());
}

/// Returns a REST API that is compliant with the [Pub Server spec](https://github.com/dart-lang/pub/blob/master/doc/repository-spec-v2.md).
Router getRouter() => Router()
  ..get("/api/packages/<package>/advisories", getAdvisories)
  ..get("/api/packages/<package>", getVersions)
  ..get("/api/archives/<package>-<version>.tar.gz", getTarball);
