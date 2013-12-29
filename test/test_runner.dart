import 'dart:io';

import 'package:unittest/unittest.dart';
import 'package:gloss/gloss.dart';
import 'package:gloss/src/lexer.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;

void main() {
  testYAMLSpecs (FileSystemEntity fileEntity) {
    if (!fileEntity.path.endsWith('yaml')) {
      return;
    }
    
    var yamlContent = new File(fileEntity.path).readAsStringSync();
    final Map yamlDoc = loadYaml(yamlContent);
    
    for (var groupName in yamlDoc.keys) {
      group(groupName, () {
        final Map cases = yamlDoc[groupName];
        
        for (var testCaseName in cases.keys) {
          test(testCaseName, () {
            final List testCase = cases[testCaseName];
            
            for (var spec in testCase) {
              var transcription;
              
              switch (spec['transformer']) {
                case 'parser':
                  transcription = Gloss.parse(spec['code']);
                  
                  break;
                  
                case 'lexer':
                  transcription = new Lexer(spec['code']).tokenize();
                  
                  break;
                default:
                  break;
              }
              
              
              switch (spec['policy']) {
                case 'length':
                  expect(transcription, hasLength(spec['value']));
                  
                  break;
                  
                case 'noWhiteSpace':
                  expect(transcription, equalsIgnoringWhitespace(spec['value']));
                  
                  break;
                  
                case 'equals':
                  expect(transcription, equals(spec['value']));
                  
                  break;
                  
                default:
                  break;
              }
            }
            
          });
        }
        
      });
    }
  }
  
  final files = new Directory(path.dirname(Platform.script.path)).listSync();
  files.forEach(testYAMLSpecs);
}