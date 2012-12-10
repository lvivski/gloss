library parser;

import 'lexer.dart';
import 'nodes.dart';

class Parser {
  List<String> _state = ['stylesheet'];
  List<List<Object>> _stash = [], _tokens; 
  Stylesheet _root;
  num _parens = 0;
  bool _operand = false;

  Parser(str) {
    this._tokens = new Lexer(str).tokenize();
    this._root = new Stylesheet();
  }

  String get _currentState => _state.last;

  parse() {
    var block = _root;
    while (peek[0] != 'eos') {
      if (_accept('newline') != null) {
        continue;
      }
      var smt = _statement();
      _accept(';');
      if (smt == null) {
        _error('unexpected token {peek}, not allowed at the root level');
      }
      block.push(smt);
    }
    return block;
  }

  void _error(msg) {
    var tag = peek[0],
        val = peek[1] == null
          ? ''
          : ' $peek';
    if (val.trim() == tag.trim()) {
      val = '';
    }
    throw new Exception(msg.replaceAll('{peek}', '"$tag$val"'));
  }

  List<Object> get peek => _tokens[0];

  List<Object> get next {
    var tok = _stash.length > 0
      ? _stash.removeLast()
      : _tokens.removeAt(0);

    return tok;
  }

  List<Object> _accept(tag) {
    if (peek[0] == tag) {
      return next;
    }
  }

  List<Object> _expect(tag) {
    if (peek[0] != tag) {
      _error('expected "$tag", got {peek}');
    }
    return next;
  }

  List<Object> lookahead(n) => _tokens[--n];

  bool _lineContains(tag) {
    var i = 1;

    while (i++ < _tokens.length) {
      var la = lookahead(i++);
      if (['indent', 'outdent', 'newline'].indexOf(la[0]) != -1) {
        return false;
      }
      if (la[0] == tag) {
        return true;
      }
    }
    return false;
  }

  void _skipWhitespace() {
    while (['space', 'indent', 'outdent', 'newline'].indexOf(peek[0]) != -1) {
      next;
    }
  }

  void _skipNewlines() {
    while (peek[0] == 'newline') {
      next;
    }
  }

  void _skipSpaces() {
    while (peek[0] == 'space') {
      next;
    }
  }

  bool _looksLikeDefinition(i) {
    return lookahead(i)[0] == 'indent'
          || lookahead(i)[0] == '{';
  }

  Node _statement() {
    var tag = peek[0];
    switch(tag) {
      case 'selector':
        return _selector();
      case 'dimension':
        return _dimension();
      case 'atkeyword':
        return _atkeyword();
      case 'ident':
        return _ident();
      case 'fn':
        return _fn();
      case 'comment':
        return _comment();
      default:
        _error('unexpected {peek}');
    }
  }

  Ruleset _selector() {
    var ruleset = new Ruleset();

    do {
      _accept('newline');
      ruleset.push(new Selector(next[1]));
    } while (_accept(',') != null);

    _state.add('selector');
    ruleset.block = _block();
    _state.removeLast();

    return ruleset;
  }

  Block _block() {
    var block = new Block();

    _skipNewlines();
    _accept('{');
    _skipWhitespace();

    while (peek[0] != '}') {
      if (_accept('newline') != null) {
        continue;
      }
      var statement = _statement();
      _accept(';');
      _skipWhitespace();
      if (statement == null) {
        _error('unexpected token {peek} in block');
      }
      block.push(statement);
    }

    _expect('}');
    _accept('outdent');
    _skipSpaces();
    return block;
  }

  Ruleset _dimension() {
    var ruleset = new Ruleset();

    do {
      _accept('newline');
      ruleset.push(new Selector(next[1]));
    } while (_accept(',') != null);

    _state.add('selector');
    ruleset.block = _block();
    _state.removeLast();

    return ruleset;
  }

  Atrule _atkeyword() {
    var rule = '@#{next[1]}';
    while (peek[0] != '{') {
      _accept('newline');
      _accept('indent');
      rule.concat(next[1]);
    }
    var atrule = new Atrule(rule);
    _state.add('atrule');
    atrule.block = _block();
    _state.removeLast();
    return atrule;
  }

  Node _ident() {
    var i = 2;
    var la = lookahead(i)[0];

    while (la == 'space') {
      la = lookahead(++i)[0];
    }

    switch (la) {
      case '=':
        return _assignment();
      case '-':
      case '+':
      case '/':
      case '*':
      case '%':
        switch (_currentState) {
          case 'selector':
          case 'atrule':
            return _declaration();
        }
        break;
      default:
        switch (_currentState) {
          case 'root':
            return _selector();
          case 'selector':
          case 'function':
          case 'atrule':
            return _declaration();
          default:
            var tok = _expect('ident');
            _accept('space');
            return new Ident(tok[1]);
        }
    }
  }

  Node _declaration() {
    var ident = _accept('ident')[1],
        decl = new Declaration(ident),
        ret = decl;

    _accept('space');
    if (_accept(':') != null) _accept('space');

    _state.add('declaration');
    decl.value = _list();
    if (decl.value.isEmpty) {
      ret = ident;
    }
    _state.removeLast();
    _accept(';');

    return ret;
  }

  Expression _list() {
    var node = _expression();
    while (_accept(',') != null || _accept('indent') != null) {
      if (node.isList) {
        node.push(_expression());
      } else {
        var list = new Expression(true);
        list.push(node);
        list.push(_expression());
        node = list;
      }
    }
    return node;
  }

  Node _assignment() {
    var name = _expect('ident')[1];

    _accept('space');
    _expect('=');

    _state.add('assignment');
    var expr = _list(),
        node = new Ident(name, expr);
    _state.removeLast();

    return node;
  }

  Expression _expression() {
    var expr = new Expression();
    Node node;

    _state.add('expression');
    while ((node = _additive()) != null) {
      expr.push(node);
    }
    _state.removeLast();
    return expr;
  }

  Node _additive() {
    var node = _multiplicative();
    List op;

    while ((op = _accept('+')) != null || (op = _accept('-')) != null) {
      _operand = true;
      node = new Binop(op[0], node, _multiplicative());
      _operand = false;
    }
    return node;
  }

  Node _multiplicative() {
    var node = _primary();
    List op;
    
    while ((op = _accept('*')) != null
      || (op = _accept('/')) != null
      || (op = _accept('%')) != null) {
      _operand = true;
      if (op == '/' && _currentState == 'declaration' && _parens == 0) {
        _stash.add(['literal', '/']);
        _operand = false;
        return node;
      } else {
        if (node != null) {
          _error('illegal unary "$op", missing left-hand operand');
        }
        node = new Binop(op[0], node, _primary());
        _operand = false;
      }
    }
    return node;
  }

  Node _primary() {
    if (_accept('(') != null) {
      ++_parens;
      var expr = _expression();
      _expect(')');
      --_parens;
      if(_accept('%') != null) {
        expr.push('%');
      }
      return expr;
    }

    switch (peek[0]) {
      case 'dimension':
      case 'color':
      case 'string':
      case 'literal':
        return next[1];
      case 'ident':
        return _ident();
      case 'fn':
        return _fncall();
    }
  }

  Node _fn() {
    var p = 1,
        i = 2,
        out = false;
    List tok; 

    while ((tok = this.lookahead(i++)) != null) {
      switch (tok[0]) {
        case 'fn':
        case '(':
          ++p;
          break;
        case ')':
          if (--p == 0) {
            out = true;
          }
          break;
        case 'eos':
          _error('failed to find closing paren ")"');
          break;
      }
      if (out) break;
    }
    switch (_currentState) {
      case 'expression':
        return _fncall();
      default:
        return _looksLikeDefinition(i)
          ? _definition()
          : _expression();
    }
  }

  Definition _definition() {
    var name = _expect('fn')[1];

    _state.add('function params');
    _skipWhitespace();
    var params = _params();
    _skipWhitespace();
    _expect(')');
    _state.removeLast();

    _state.add('function');
    var f = new Definition(name, params);
    f.block = _block();
    _state.removeLast();
    return f;
  }

  Call _fncall() {
    String name = _expect('fn')[1];
    _state.add('function arguments');
    ++_parens;
    Arguments args = _args();
    _expect(')');
    --_parens;
    _state.removeLast();
    return new Call(name, args);
  }

  Params _params() {
    var params = new Params();
    List tok;
    Ident node;

    while ((tok = _accept('ident')) != null) {
      _accept('space');
      params.push(node = tok[1]);
      if (_accept('=') != null) {
        node.value = _expression();
      }
      _skipWhitespace();
      _accept(',');
      _skipWhitespace();
    }
    return params;
  }

  Arguments _args() {
    var args = new Arguments();

    do {
      if (peek[0] == 'ident' && lookahead(2)[0] == '=') {
        var keyword = next[1];
        _expect('=');
        args.map[keyword] = _expression();
      } else {
        args.push(_expression());
      }
    } while (_accept(',') != null);

    return args;
  }

  _comment() {
    var node = next[1];
    _skipSpaces();
    return node;
  }

  _literal() => _expect('literal')[1];
}
