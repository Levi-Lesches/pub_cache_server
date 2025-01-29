import "dart:io";

import "package:tar/tar.dart";
import "package:path/path.dart" as p;

extension on File {
  String get filename => path.split(r"/|\").last;
}

/// Returns the tar entry name for [entry] as the file directory relative to [source]
///
/// This has the same logic as [p.Context.relative], however this allows `\` and `/`
/// to be used as path separators simultaneously
String getTarEntryName(FileSystemEntity entry, Directory source) =>
    p.posix.relative(
      entry.path.replaceAll(r"\", "/"),
      from: source.path.replaceAll(r"\", "/"),
    );

/// Returns the contents of a directory as a stream of Tar file entries.
Stream<TarEntry> getTarEntries(Directory source, String outputName) async* {
  await for (final entry in source.list(recursive: true)) {
    if (entry is! File) continue;
    final name = getTarEntryName(entry, source);
    if (name.startsWith(".")) continue;
    if (name == outputName) continue;
    final stat = entry.statSync();
    yield TarEntry(
      TarHeader(
        name: name,
        typeFlag: TypeFlag.reg,
        mode: stat.mode,
        modified: stat.modified,
        accessed: stat.accessed,
        changed: stat.changed,
        size: stat.size,
      ),
      entry.openRead(),
    );
  }
}

/// Creates a compressed tarball (`.tar.gz` file) for the given source at the given location.
Future<void> makeTarball(Directory source, File outputFile) =>
    getTarEntries(source, outputFile.filename)
        .transform(tarWriter)
        .transform(gzip.encoder)
        .pipe(outputFile.openWrite());
