import 'package:jtt_commandline/src/models/gtt_project.dart';
import 'package:xml/xml.dart';

class FileConversionService {

  TwData _twData;

  FileConversionService.from({String gttXml, String jttJson}) {
    if (gttXml != null) {
      _twData = _fromGttXml(gttXml);
    }
    if (jttJson != null) {

    }
  }

  TwData get gttTWdata => _twData;

  TwData _fromGttXml(String xmlInput) {
    final document = XmlDocument.parse(xmlInput);
    return TwData.fromXml(document.getElement('TWData'));
  }
}

