library parser;

import 'lexer.dart';
import 'nodes.dart';

class Parser {
  List tokens, stash = [], state = ['stylesheet'];
  Node root;
  num parens = 0;
  bool operand = false;
  
  Parser(str) {
    this.tokens = new Lexer(str).tokenize();
    this.root = new Stylesheet();
    this.stash = [];
    this.parens = 0;
    this.state = ['root'];
  }
  
  get currentState => state[state.length - 1];
  
  parse() {
    var block = root;
    while (peek[0] != 'eos') {
      if (accept('newline') != null)
        continue;
      var smt = statement();
      accept(';');
      if (smt == null)
        error('unexpected token {peek}, not allowed at the root level');
      block.push(smt);
    }
    return block;
  }
  
  error(msg) {
    var tag = peek[0],
        val = peek[1] == null
          ? ''
          : ' $peek';
    if (val.trim() == tag.trim())
      val = '';
    throw new Exception(msg.replaceAll('{peek}', '"$tag$val"'));
  }
  
  get peek => tokens[0];
  
  get next {
    var tok = stash.length > 0
      ? stash.removeLast()
      : tokens.removeAt(0);
      
    return tok;
  }
  
  accept(tag) {
    if (peek[0] == tag) {
      return next;
    }
  }
  
  expect(tag) {
    if (peek[0] != tag) {
      error('expected "$tag", got {peek}');
    }
    return next;
  }
  
  lookahead(n) => tokens[--n];
  
  lineContains(tag) {
    var i = 1,
        la;

    while (i++ < tokens.length) {
      la = lookahead(i++);
      if (['indent', 'outdent', 'newline'].indexOf(la[0]) != -1)
        return false;
      if (la[0] == tag)
        return true;
    }
    return false;
  }
  
  skipWhitespace() {
    while (['space', 'indent', 'outdent', 'newline'].indexOf(peek[0]) != -1)
      next;
  }

  skipNewlines() {
    while (peek[0] == 'newline')
      next;
  }

  skipSpaces() {
    while (peek[0] == 'space')
      next;
  }
  
  looksLikeDefinition(i) {
    return lookahead(i)[0] === 'indent'
          || lookahead(i)[0] === '{';
  }

  statement() {
    var tag = peek[0];
    switch(tag) {
      case 'selector':
        return selector();
      case 'dimension':
        return dimension();
      case 'atkeyword':
        return atkeyword();
      case 'ident':
        return ident();
      case 'fn':
        return fn();
      case 'comment':
        return comment();
      default:
        error('unexpected {peek}');
    }
  }
  
  selector() {
    var ruleset = new Ruleset();

    do {
      this.accept('newline');
      ruleset.push(new Selector(next[1]));
    } while (accept(',') != null);

    state.add('selector');
    ruleset.block = block();
    state.removeLast();

    return ruleset;
  }
  
  block() {
    var smt
      , b = new Block();

    skipNewlines();
    accept('{');
    skipWhitespace();

    while (peek[0] !== '}') {
      if (accept('newline') != null)
        continue;
      smt = statement();
      accept(';');
      skipWhitespace();
      if (smt == null) 
        error('unexpected token {peek} in block');
      b.push(smt);
    }

    expect('}');
    accept('outdent');
    skipSpaces();
    return b;
  }
  
  dimension() {
    var ruleset = new Ruleset();

    do {
      this.accept('newline');
      ruleset.push(new Selector(next[1]));
    } while (accept(',') != null);

    state.add('selector');
    ruleset.block = block();
    state.removeLast();

    return ruleset;
  }
  
  atkeyword() {
    var rule = '@#{next[1]}';
    while (peek[0] != '{') {
      accept('newline');
      accept('indent');
      rule.concat(next[1]);
    }
    var atrule = new Atrule(rule);
    state.add('atrule');
    atrule.block = block();
    state.removeLast();
    return atrule;
  }
  
  ident() {
    var i = 2,
        la = lookahead(i)[0];

    while (la == 'space')
      la = lookahead(++i)[0];

    switch (la) {
      case '=':
        return assignment();
      case '-':
      case '+':
      case '/':
      case '*':
      case '%':
        switch (currentState) {
          case 'selector':
          case 'atrule':
            return declaration();
        }
        break;
      default:
        switch (currentState) {
          case 'root':
            return selector();
          case 'selector':
          case 'function':
          case 'atrule':
            return declaration();
          default:
            var tok = expect('ident');
            accept('space');
            return new Ident(tok[1]);
        }
    }
  }
  
  declaration() {
    var ident = accept('ident')[1],
        decl = new Declaration(ident),
        ret = decl;

    accept('space');
    if (accept(':') != null) accept('space');

    state.add('declaration');
    decl.value = list();
    if (decl.value.isEmpty) 
      ret = ident;
    state.removeLast();
    accept(';');

    return ret;
  }
  
  list() {
    var node = expression();
    while (accept(',') != null || accept('indent') != null) {
      if (node.isList) {
        node.push(expression());
      } else {
        var list = new Expression(true);
        list.push(node);
        list.push(expression());
        node = list;
      }
    }
    return node;
  }
  
  assignment() {
    var name = expect('ident')[1];

    accept('space');
    expect('=');

    state.add('assignment');

    var expr = list(),
        node = new Ident(name, expr);

    state.removeLast();

    return node;
  }
  
  expression() {
    var node,
        expr = new Expression();
    
    state.add('expression');
    while ((node = additive()) != null) {
      expr.push(node);
    }
    state.removeLast();
    return expr;
  }
  
  additive() {
    var op,
        node = multiplicative();
    
    while ((op = accept('+')) != null || (op = accept('-')) != null) {
      operand = true;
      node = new Binop(op[0], node, multiplicative());
      operand = false;
    }
    return node;
  }

  multiplicative() {
    var op,
        node = primary();
    while ((op = accept('*')) != null
      || (op = accept('/')) != null
      || (op = accept('%')) != null) {
      operand = true;
      if (op == '/' && currentState == 'declaration' && parens == 0) {
        stash.add(['literal', '/']);
        operand = false;
        return node;
      } else {
        if (node != null) 
          error('illegal unary "$op", missing left-hand operand');
        node = new Binop(op[0], node, primary());
        operand = false;
      }
    }
    return node;
  }
  
  primary() {
    var op,
        node;

    if (accept('(') != null) {
      ++parens;
      var expr = expression();
      expect(')');
      --parens;
      if(accept('%') != null) 
        expr.push('%');
      return expr;
    }

    switch (peek[0]) {
      case 'dimension':
      case 'color':
      case 'string':
      case 'literal':
        return next[1];
      case 'ident':
        return ident();
      case 'function':
        return fncall();
    }
  }
  
  fn() {
    var p = 1,
        i = 2,
        tok;
    
    out:
    while ((tok = this.lookahead(i++)) != null) {
      switch (tok.tag) {
        case 'function':
        case '(':
          ++p;
          break;
        case ')':
          if (--p == 0)
            break out;
          break;
        case 'eos':
          error('failed to find closing paren ")"');
          break;
      }
    }
    switch (this.currentState) {
      case 'expression':
        return fncall();
      default:
        return looksLikeDefinition(i)
          ? definition()
          : expression();
    }
  }
  
  definition() {
    var name = expect('fn')[1];

    state.add('function params');
    skipWhitespace();
    var par = params();
    skipWhitespace();
    expect(')');
    state.removeLast();

    state.add('function');
    var f = new Definition(name, par);
    f.block = block();
    state.removeLast();
    return f;
  }
  
  fncall() {
    var name = expect('fn')[1];
    state.add('function arguments');
    ++parens;
    var a = args();
    expect(')');
    --parens;
    state.removeLast();
    return new Call(name, a);
  }
  
  params() {
    var tok,
        node,
        p = new Params();

    while ((tok = accept('ident')) != null) {
      accept('space');
      p.push(node = tok[1]);
      if (accept('=') != null) {
        node.value = expression();
      }
      skipWhitespace();
      accept(',');
      skipWhitespace();
    }
    return p;
  }
  
  args() {
    var a = new Arguments(),
        keyword;

    do {
      if (peek[0] == 'ident' && lookahead(2)[0] == '=') {
        keyword = next[1];
        expect('=');
        a.map[keyword] = expression();
      } else {
        a.push(expression());
      }
    } while (accept(',') != null);
    
    return a;
  }

  comment() {
    var node = next[1];
    skipSpaces();
    return node;
  }

  literal() => expect('literal')[1];
}
