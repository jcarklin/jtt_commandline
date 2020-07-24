
import 'package:jtt_commandline/src/models/tablet.dart';

enum ProjectType {
  tabletWeaving,
}

enum PatternType {
  threadedIn,
  doubleWeave,
  brokenTwill
}

class Project {
  ProjectType _projectType = ProjectType.tabletWeaving;
  PatternType _patternType = PatternType.threadedIn;
  String patternSource = 'jtt';
  List<Tablet> pack = [];


}