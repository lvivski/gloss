import 'dart:html';

import 'packages/gloss/src/rewriter.dart';
import 'packages/gloss/src/lexer.dart';

main () {
  final sourceTextArea = querySelector('textarea');
  final performRewrite = querySelector('#performRewrite');
  final astTable = querySelector('.floatbox.ast');
  final validatorBuilder = new NodeValidatorBuilder();
  validatorBuilder.allowHtml5();
  
  renderAST (source) {
    var tokens = new Lexer(source).tokenize();
    
    if (performRewrite.checked) {
      tokens = new Rewriter(tokens).rewrite();
    }
    
    astTable.children.clear();
    
    tokens.forEach((List token) {
      var tokenName = token[0];
      var tokenParams = token.sublist(1);
      
      astTable.append(new Element.html([
        '<div class="token">',
          '<span class="name">', tokenName,'</span>','<span class="args">', tokenParams.join(' '), '</span>',
        '</div>'
      ].join(), validator: validatorBuilder));
    });
  }
  
  HttpRequest.getString('astviewer.gloss').then((glossStyles) {
    sourceTextArea.value = glossStyles;
  });
  
  querySelector('.button-lexer').onClick.listen((MouseEvent event) => renderAST(sourceTextArea.value));
}