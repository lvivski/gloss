import '../lib/gloss.dart';

main() {
  var src =r'''
clr = #ddd

.a
  color: red
  background: url(image.png),#fff
  background: #fff, #000
  &:hover
    color: add(blue, green)
    margin: 10 + 15px
  .b & {
    color: $clr
  }
''';
  print(Gloss.parse(src));
}