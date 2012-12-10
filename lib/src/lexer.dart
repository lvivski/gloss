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
  String _str;
  List _stash = [],
    _indentStack = [],
    _prev;

  num lineno = 1,
      _prevIndents = 0;

  bool _isURL = false;

  RegExp _indentRe;

  Lexer(this._str);

  Match _match(type) {
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

    return re[type].firstMatch(_str);
  }

  List tokenize() {
    var tok,
        tmp = _str,
        tokens = [];

    while ((tok = next)[0] != 'eos') {
      tokens.add(tok);
    }

    _str = tmp;
    _prevIndents = 0;

    tokens.add(tok);

    Rewriter rw = new Rewriter(tokens);

    return rw.rewrite();
  }

  List get next {
    List t = _stashed();
    List tok = t != null ? t : _advance();

    switch (tok[0]) {
      case 'newline':
      case 'indent':
        ++lineno;
        break;
      case 'outdent':
        if (_prev[0] != 'outdent') {
          ++lineno;
        }
        break;
    }

    _prev = tok;
    if (tok.length < 2) {
      tok.add(null);
    }
    tok.add(lineno);
    return tok;
  }
  
  void _skip(len) {
    _str = _str.substring(len is Match
      ? len.group(0).length
      : len);
  }

  List _stashed() => _stash.length > 0 ? _stash.removeAt(0) : null;

  List _advance() {
    var t;
    if ((t = _eos()) != null
       || (t = _sep()) != null
       || (t = _url()) != null
       || (t = _atkeyword()) != null
       || (t = _comment()) != null
       || (t = _newline()) != null
       || (t = _important()) != null
       || (t = _fn()) != null
       || (t = _brace()) != null
       || (t = _paren()) != null
       || (t = _color()) != null
       || (t = _string()) != null
       || (t = _dimension()) != null
       || (t = _ident()) != null
       || (t = _operator()) != null
       || (t = _space()) != null
       || (t = _selector()) != null
       ){ return t; }
    throw new Exception('parse error');
  }

  List _eos() {
    if (_str.length > 0) return null;
    if (_indentStack.length > 0) {
      _indentStack.removeAt(0);
      return ['outdent'];
    } else {
      return ['eos'];
    }
  }

  List _sep() {
    Match match = _match('sep');
    if (match != null) {
      _skip(match);
      return [';'];
    }
  }

  List _url() {
    if (!_isURL) return null;
    Match match = _match('urlchars');
    if (match != null) {
      _skip(match);
      return ['literal', new Literal(match.group(0))];
    }
  }

  List _atkeyword() {
    Match match = _match('atkeyword');
    if (match != null) {
      _skip(match);
      var type = match.group(1);
      if (match.group(2) != null) {
        type = 'keyframes';
      }
      return ['atkeyword', type];
    }
  }

  List _comment() {
    Match match = _match('comment');
    if (match != null) {
      var lines = match.group(0).split('\n').length;
      lineno += lines;
      _skip(match);
      return ['comment', new Comment(match.group(0))];
    }
  }

  List _newline() {
    RegExp re;
    Match match;

    if (_indentRe != null) {
      match = _indentRe.firstMatch(_str);
    } else {
      re = new RegExp(r'^\n([\t]*)[ \t]*', multiLine: true); // tabs
      match = re.firstMatch(_str);

      if (match != null && match.group(1).length == 0) {
        re = new RegExp(r'^\n([ \t]*)', multiLine: true); // spaces
        match = re.firstMatch(_str);
      }

      if (match != null && match.group(1).length > 0) {
        _indentRe = re;
      }
    }

    if (match != null) {
      var tok
        , indents = match.group(1).length;

      _skip(match);

      if (_str.length > 0 && (_str[0] == ' ' || _str[0] == '\t')) {
        throw new Exception('Invalid indentation. You can use tabs or spaces to indent, but not both.');
      }

      if (_str.length > 0 && _str[0] == '\n') {
        ++lineno;
        return _advance();
      }
      // Outdent
      if (_indentStack.length > 0 && indents < _indentStack[0]) {
        while (_indentStack.length > 0 && _indentStack[0] > indents) {
          _stash.add(['outdent']);
          _indentStack.removeAt(0);
        }
        tok = _stash.removeLast();
      // Indent
      } else if (indents > 0 && indents != (_indentStack.length > 0 ? _indentStack[0] : false)) {
        _indentStack.insertRange(0, 1, indents);
        tok = ['indent'];
      // Newline
      } else {
        tok = ['newline'];
      }
      return tok;
    }
  }

  List _important() {
    Match match = _match('important');
    if (match != null) {
      _skip(match);
      return ['id', '!important'];
    }
  }

  List _fn() {
    Match match = _match('function');
    if (match != null) {
      _skip(match);
      var name = match.group(1);
      _isURL = 'url' == name;
      return ['fn', name];
    }
  }

  List _brace() {
    Match match = _match('brace');
    if (match != null) {
      _skip(1);
      return [match.group(1)];
    }
  }

  List _paren() {
    Match match = _match('paren');
    if (match != null) {
      var paren = match.group(1);
      _skip(match);
      if (paren == ')') {
        _isURL = false;
      }
      return [paren];
    }
  }

  List _color() {
    Match match = _match('color');
    if (match != null) {
      _skip(match);
      return ['color', new Color(match.group(1))];
    }
  }

  List _string() {
    Match match = _match('string');
    if (match != null) {
      var s = match.group(1),
        quote = match.group(0)[0];
      _skip(match);
      s = s.substring(1, s.length - 1).replaceAll('\n', '\n');
      return ['string', new Str(s, quote)];
    }
  }

  List _dimension() {
    Match match = _match('dimension');
    if (match != null) {
      _skip(match);
      return ['dimension', new Dimension(match.group(1), match.group(2))];
    }
  }

  List _ident() {
    Match match = _match('ident');
    if (match != null) {
      _skip(match);
      return ['ident', match.group(1)];
    }
  }

  List _operator() {
    Match match = _match('operator');
    if (match != null) {
      var op = match.group(1);
      _skip(match);
      _isURL = false;
      return [op];
    }
  }

  List _space() {
    Match match = _match('space');
    if (match != null) {
      _skip(match);
      return ['space'];
    }
  }

  List _selector() {
    Match match = _match('selector');
    if (match != null) {
      var selector = match.group(0);
      _skip(match);
      return ['selector', selector];
    }
  }

}
