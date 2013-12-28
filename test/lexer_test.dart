import 'dart:io';

import 'package:unittest/unittest.dart';
import 'package:gloss/src/lexer.dart';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as path;

void main() {
  var yamlDocPath = path.joinAll([path.dirname(Platform.script.path), 'lexer_cases.yaml']);
  var yamlContent = new File(yamlDocPath).readAsStringSync();
  final Map yamlDoc = loadYaml(yamlContent);
  
  group('lexer', () {
    for (var caseName in yamlDoc.keys) {
      final codeSnippet = yamlDoc[caseName]['code'];
      final expectedStructure = yamlDoc[caseName]['expect'];
      
      test(caseName, () {
        var t = new Lexer(codeSnippet).tokenize();
        expect(t, equals(expectedStructure));
      });
    }
  });
}