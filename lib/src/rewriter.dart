library rewriter;

class Rewriter {
  List tokens;
  
  const EXPRESSION_START = const ['{', 'indent'],
    EXPRESSION_END = const ['}', 'outdent'],
    LINEBREAKS = const ['newline', 'indent', 'outdent'];
  
  Rewriter(this.tokens);
  
  rewrite() {
    return addImplicitBraces()
           .findSelectors()
           .tokens;
  }
  
  scan(block) {
    var i = 0,
        token;
    while (i < tokens.length) {
      token = tokens[i];
      i += block(token, i, tokens);
    }
    return this;
  }
  
  addImplicitBraces() {
    var stack = [],
        sameLine = true,
        tok,
        condition = (token, i) {
          var tag = token[0];
          if (LINEBREAKS.indexOf(tag) != -1)
            sameLine = false;
          return (tag === 'newline' || tag === 'outdent') && sameLine;
        },
        action = (token, i) {
          var tok = ['}', false, token[2]];
          return tokens.insertRange(i, 1, tok);
        };
        
    return scan((token, i, tokens) {
      var tag = token[0],
          last, tok;

      if (EXPRESSION_START.indexOf(tag) != -1) {
        stack.add([(tag == 'indent' && tokens[i - 1][0] == '{' ? '{' : tag), i]);
        return 1;
      }

      if (EXPRESSION_END.indexOf(tag) != -1) {
        stack.removeRange(0, 1);
        return 1;
      }

      if (!((tag == 'ident' || tag == 'dimension' || tag == 'selector') && stack.length > 0 && stack[stack.length - 1][0] != '{'))
        return 1;

      sameLine = true;
      stack.add(['{']);
      tok = ['{', null, token[2]];
      tokens.insertRange(i - 1, 1, tok);

      detectEnd(i + 2, condition, action);
      return 1;
    });
  }
  
  findSelectors() {
    return scan((token, i, tokens) {
      if (token[0] == 'ident' && (tokens[i + 1][0] == '{')) {
        token[0] = 'selector';
      }
      if (token[0] == 'ident' && (tokens[i + 1][0] === 'space' && tokens[i + 2][0] === 'selector')) {
        token[0] = 'selector';
        token[1] += ' ${tokens[i + 2][1]}';
        tokens.removeRange(i + 1, 2);
      }
      return 1;
    });
  }
  
  detectEnd(i, condition, action) {
    var levels = 0,
        token;
    while (i < tokens.length) {
      token = tokens[i];
      if (levels == 0 && condition(token, i)) {
        return action(token, i);
      }
      if (levels < 0) {
        return action(token, i - 1);
      }
      if (EXPRESSION_START.indexOf(token[0]) != -1) {
        ++levels;
      } else if (EXPRESSION_END.indexOf(token[0]) != -1) {
        --levels;
      }
      ++i;
    }
    return i - 1;
  }
}

