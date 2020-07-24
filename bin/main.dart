import 'dart:io';
import 'package:jtt_commandline/src/service/gttConversion.dart';
import 'package:prompter_jtt/prompter_jtt.dart';

void main(List<String> arguments) {

  final prompter = Prompter();
  if (!prompter.askBinary('Would you like to convert a tablet weaving file?')) {
    exit(0);
  }
  final fromFormat = prompter.askMultiple('Select conversion format: ', buildFormatOptions());
  final File selectedFile = prompter.askMultiple('Select the file to convert: ', buildFileOptions(fromFormat));

  GttConversion conversion = GttConversion(xmlInput: selectedFile.readAsStringSync());

}

List<Option> buildFileOptions(extension) {
  return Directory.current
      .listSync()
      .where((element) {
        return FileSystemEntity.isFileSync(element.path)
            && element.path.contains(RegExp(r'\.('+extension+')'));
      }).map((file) {
        final filename = file.path.split(Platform.pathSeparator).last;
        return Option(filename, file);
      }).toList();
}

List<Option> buildFormatOptions() {
  return [
    Option('Convert from gtt to jtt', 'gtt'),
    Option('Convert from jtt to gtt', 'jtt'),
  ];
}



