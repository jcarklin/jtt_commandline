import 'dart:io';

import 'package:jtt_commandline/src/service/file_conversion_service.dart';
import 'package:prompter_jtt/prompter_jtt.dart';

Future<void> main(List<String> arguments) async {

  final prompter = Prompter();

  final fromFormat = prompter.askMultiple('Select conversion format: ', buildFormatOptions());
  final File selectedFile = prompter.askMultiple('Select the file to convert: ', buildFileOptions(fromFormat));

  final fileConversionService = fromFormat=='gtt'
      ?FileConversionService.fromGtt(selectedFile)
      :FileConversionService.fromJtt(selectedFile);
  print(fileConversionService.gttTWdata);
  print(fileConversionService.jttProject);

  fromFormat=='gtt'
      ?print(await fileConversionService.writeAsJttFile())
      :print(await fileConversionService.writeAsGttFile());
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



