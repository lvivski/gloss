library gloss;

import 'package:gloss/gloss.dart';
import 'package:gloss/watch.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

main () {
  new Watch('./gloss').match('.glos').listen((fse) {
    if (fse.type == FileSystemEvent.DELETE) {
      var output = new File(path.withoutExtension(fse.path) + '.css');
      output.exists().then((e) {
        if (e) output.delete();
      });
    } else {
      new File(fse.path).readAsString().then((data) {
        new File(path.withoutExtension(fse.path) + '.css').open(mode: FileMode.WRITE).then((dst) {
          dst.writeString(Gloss.parse(data));
        });
      });
    }
  });
}
