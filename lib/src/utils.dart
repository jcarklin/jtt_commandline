import 'dart:io';

Future<String> toFile(String filename, String fileContents) {
  return Future.sync(() {
    try {
      File(filename).writeAsString(fileContents);
      return 'File $filename successfully written';
    } catch (e) {
      return 'Writing File $filename Failed!!';
    }
  });
}
