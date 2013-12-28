import 'dart:io';

import 'package:unittest/unittest.dart';
import 'package:gloss/gloss.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;

void main() {
  var yamlDocPath = path.joinAll([path.dirname(Platform.script.path), 'gloss_cases.yaml']);
  var yamlContent = new File(yamlDocPath).readAsStringSync();
  final Map yamlDoc = loadYaml(yamlContent);
  
  for (var groupName in yamlDoc.keys) {
    group(groupName, () {
      final Map cases = yamlDoc[groupName];
      
      for (var testCaseName in cases.keys) {
        test(testCaseName, () {
          final List testCase = cases[testCaseName];
          
          for (var spec in testCase) {
            switch (spec['policy']) {
              case 'length':
                expect(Gloss.parse(spec['code']), hasLength(spec['value']));
                
                break;
                
              case 'noWhiteSpace':
                expect(Gloss.parse(spec['code']), equalsIgnoringWhitespace(spec['value']));
                
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