import "dart:convert";
import "dart:io";
import "dart:typed_data";

import "package:archive/archive_io.dart";

const pubCache = r"D:\.tools\pub\hosted\pub.dev";
const host = "0.0.0.0";
const port = 8000;

extension on Directory {
  String operator /(String other) => "$path/$other";
}

typedef Json = Map<String, dynamic>;

void main() {
  print("Hello, World! s");
}

Json getAdvisories(_) => {
  "advisories": const <void>[],
  "advisoriesUpdated": DateTime.now().toIso8601String(),
};

Json? getVersions(String package) {
  final cache = File("$pubCache/.cache/$package-versions.json");
  if (!cache.existsSync()) return null;
  final versionContents = cache.readAsStringSync();
  final versionData = jsonDecode(versionContents);
  int? versionNumber;
  for (final version in versionData["versions"]) {
    versionNumber = version["version"] as int;
    version["archive_url"] = "http://$host:$port/api/archives/$package-$versionNumber.tar.gz";
    version["archive_sha256"] = null;
  }
  versionData["archive_url"] = "http://$host:$port/api/archives/$package-$versionNumber.tar.gz";
  versionData["archive_sha256"] = null;
  return versionData;
}

Uint8List? getTarball(String package, String version) {
  final packageDir = Directory("$pubCache\\$package-$version");
  if (!packageDir.existsSync()) return null;
  final tarballsDir = Directory(packageDir / ".tarballs");
  tarballsDir.createSync();
  final output = File(tarballsDir / "$package-$version.tar.gz");
  if (!output.existsSync()) makeTarball(packageDir, output);
  return output.readAsBytesSync();
}

void makeTarball(Directory source, File outputFile) {
  final archive = createArchiveFromDirectory(source);
  final encoder = GZipEncoder();
  final tar = TarEncoder();
  final output = OutputFileStream.withFileHandle(FileHandle.fromFile(outputFile));
  tar.encode(archive);
  encoder.encode(archive, output: output);
}
