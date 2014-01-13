import 'dart:io';

import 'package:gloss/gloss.dart';
import 'package:gloss/src/lexer.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;

void main() {
  final stopWatch = new Stopwatch();
  
  runBenchmarks (FileSystemEntity fileEntity) {
    if (!fileEntity.path.endsWith('yaml')) {
      return;
    }
    
    var yamlContent = new File(fileEntity.path).readAsStringSync();
    final Map yamlDoc = loadYaml(yamlContent);
    
    for (var groupName in yamlDoc.keys) {
      final Map cases = yamlDoc[groupName];
        
      for (var testCaseName in cases.keys) {
        final List testCase = cases[testCaseName];

        for (var i = 0, len = testCase.length; i < len; i++) {
          final spec = testCase[0];
          final transformer = spec['transformer']; 

          stopWatch.start();
          
          switch (transformer) {
            case 'parser':
              Gloss.parse(spec['code']);
                  
              break;
                  
            case 'lexer':
              new Lexer(spec['code']).tokenize();
                  
              break;
            default:
              break;
          }
          
          stopWatch.stop();
          print("${transformer.toUpperCase()}: ${groupName}/${testCaseName} #${i+1}: took ${stopWatch.elapsedMilliseconds} ms");
          stopWatch.reset();
        }           
      }
    }
  }
  
  final files = new Directory(path.dirname(Platform.script.path)).listSync();
  files.forEach(runBenchmarks);
}