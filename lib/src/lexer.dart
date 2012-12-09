library lexer;

import 'nodes.dart';
import 'rewriter.dart';

List units = [
  'em', 'ex', 'ch', 'rem', // relative lengths
  'vw', 'vh', 'vmin', // relative viewport-percentage lengths
  'cm', 'mm', 'in', 'pt', 'pc', 'px', // absolute lengths
  'deg', 'grad', 'rad', 'turn', // angles
  's', 'ms', // times
  '%', // percentage type
  'fr', // grid-layout (http://www.w3.org/TR/css3-grid-layout/)
];

class Lexer {
  String str;
  List stash = [],
    indentStack = [],
    prev;

  num lineno = 1,
      prevIndents = 0;

  bool isURL = false;

  var indentRe;

  Lexer(this.str);

  Match match(type) {
    var re = {
      'sep': new RegExp(r'^;[ \t]*'),
      'space': new RegExp(r'^([ \t]+)'),
      'urlchars': new RegExp(r'^[^\(\)]+'),
      'operator': new RegExp(r'^([.]{2,3}|[~^$*|]=|[-+*\/%]|[,:=])[ \t]*'),
      'atkeyword': new RegExp('^@(import|(?:-(\w+)-)?keyframes|charset|font-face|page|media)[ \t]*'),
      'important': new RegExp('^!important[ \t]*'),
      'brace': new RegExp(r'^([{}])[ \t]*'),
      'comment': new RegExp(r'^\/\*(?:[^*]|\*+[^\/*])*\*+\/\n?|^\/\/.*'),
      'paren': new RegExp(r'^([()])[ \t]*'),
      'function': new RegExp(r'^(-?[_a-zA-Z$-]*)\([ \t]*'),
      'ident': new RegExp(r'^(-?[_a-zA-Z$-]+)'),
      'string': new RegExp('^("[^"]*"|\'[^\']*\')[ \t]*'),
      'color': new RegExp(r'^#([a-fA-F0-9]{6}|[a-fA-F0-9]{3})[ \t]*'),
      'dimension': new RegExp('^(-?\\d*\\.?\\d+)(${Strings.join(units, '|')})?[ \\t]*'),
      'selector': new RegExp(r'^[^{\n,]+')
    };

    return re[type].firstMatch(str);
  }

  tokenize() {
    var tok,
        tmp = str,
        tokens = [];

    while ((tok = next())[0] != 'eos') {
      tokens.add(tok);
    }

    str = tmp;
    prevIndents = 0;

    tokens.add(tok);

    Rewriter rw = new Rewriter(tokens);

    return rw.rewrite();
  }

  skip(len) {
    str = str.substring(len is Match
      ? len.group(0).length
      : len);
  }

  next() {
    var t;
    var tok = (t = stashed()) is List ? t : advance();

    switch (tok[0]) {
      case 'newline':
      case 'indent':
        ++lineno;
        break;
      case 'outdent':
        if (prev[0] != 'outdent') {
          ++lineno;
        }
        break;
    }

    prev = tok;
    if (tok.length < 2) {
      tok.add(null);
    }
    tok.add(lineno);
    return tok;
  }

  stashed() => stash.length > 0 ? stash.removeAt(0) : false;

  advance() {
    var t;
    if ((t = eos()) != null
      ||(t = sep()) != null
      ||(t = url()) != null
      ||(t = atkeyword()) != null
      ||(t = comment()) != null
      ||(t = newline()) != null
      ||(t = important()) != null
      ||(t = fn()) != null
      ||(t = brace()) != null
      ||(t = paren()) != null
      ||(t = color()) != null
      ||(t = string()) != null
      ||(t = dimension()) != null
      ||(t = ident()) != null
      ||(t = operator()) != null
      ||(t = space()) != null
      ||(t = selector()) != null
        ) { return t;
    }
    throw new Exception('parse error');
  }

  eos() {
    if (str.length > 0) return;
    if (indentStack.length > 0) {
      indentStack.removeAt(0);
      return ['outdent'];
    } else {
      return ['eos'];
    }
  }

  sep() {
    Match capture = match('sep');
    if (capture != null) {
      skip(capture);
      return [';'];
    }
  }

  url() {
    if (!isURL) return;
    Match capture = match('urlchars');
    if (capture != null) {
      skip(capture);
      return ['literal', new Literal(capture.group(0))];
    }
  }

  atkeyword() {
    Match capture = match('atkeyword');
    if (capture != null) {
      skip(capture);
      var type = capture.group(1);
      if (capture.group(2) != null) {
        type = 'keyframes';
      }
      return ['atkeyword', type];
    }
  }

  comment() {
    Match capture = match('comment');
    if (capture != null) {
      var lines = capture.group(0).split('\n').length;
      lineno += lines;
      skip(capture);
      return ['comment', new Comment(capture.group(0))];
    }
  }

  newline() {
    var re, capture;

    if (indentRe != null) {
      capture = indentRe.firstMatch(str);
    } else {
      re = new RegExp(r'^\n([\t]*)[ \t]*', multiLine: true); // tabs
      capture = re.firstMatch(str);

      if (capture != null && capture.group(1).length == 0) {
        re = new RegExp(r'^\n([ \t]*)', multiLine: true); // spaces
        capture = re.firstMatch(str);
      }

      if (capture != null && capture.group(1).length > 0) {
        indentRe = re;
      }
    }

    if (capture != null) {
      var tok
        , indents = capture.group(1).length;

      skip(capture);

      if (str.length > 0 && (str[0] == ' ' || str[0] == '\t')) {
        throw new Exception('Invalid indentation. You can use tabs or spaces to indent, but not both.');
      }

      if (str.length > 0 && str[0] == '\n') {
        ++lineno;
        return advance();
      }
      // Outdent
      if (indentStack.length > 0 && indents < indentStack[0]) {
        while (indentStack.length > 0 && indentStack[0] > indents) {
          stash.add(['outdent']);
          indentStack.removeAt(0);
        }
        tok = stash.removeLast();
      // Indent
      } else if (indents > 0 && indents != (indentStack.length > 0 ? indentStack[0] : false)) {
        indentStack.insertRange(0, 1, indents);
        tok = ['indent'];
      // Newline
      } else {
        tok = ['newline'];
      }
      return tok;
    }
  }

  important() {
    Match capture = match('important');
    if (capture != null) {
      skip(capture);
      return ['id', '!important'];
    }
  }

  fn() {
    Match capture = match('function');
    if (capture != null) {
      skip(capture);
      var name = capture.group(1);
      isURL = 'url' == name;
      return ['fn', name];
    }
  }

  brace() {
    Match capture = match('brace');
    if (capture != null) {
      skip(1);
      return [capture.group(1)];
    }
  }

  paren() {
    Match capture = match('paren');
    if (capture != null) {
      var paren = capture.group(1);
      skip(capture);
      if (paren == ')') {
        isURL = false;
      }
      return [paren];
    }
  }

  color() {
    Match capture = match('color');
    if (capture != null) {
      skip(capture);
      return ['color', new Color(capture.group(1))];
    }
  }

  string() {
    Match capture = match('string');
    if (capture != null) {
      var s = capture.group(1),
        quote = capture.group(0)[0];
      skip(capture);
      s = s.substring(1, s.length - 1).replaceAll('\n', '\n');
      return ['string', new Str(s, quote)];
    }
  }

  dimension() {
    Match capture = match('dimension');
    if (capture != null) {
      skip(capture);
      return ['dimension', new Dimension(capture.group(1), capture.group(2))];
    }
  }

  ident() {
    Match capture = match('ident');
    if (capture != null) {
      skip(capture);
      return ['ident', capture.group(1)];
    }
  }

  operator() {
    Match capture = match('operator');
    if (capture != null) {
      var op = capture.group(1);
      skip(capture);
      isURL = false;
      return [op];
    }
  }

  space() {
    Match capture = match('space');
    if (capture != null) {
      skip(capture);
      return ['space'];
    }
  }

  selector() {
    Match capture = match('selector');
    if (capture != null) {
      var selector = capture.group(0);
      skip(capture);
      return ['selector', selector];
    }
  }

}
