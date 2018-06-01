  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

Is there an error with misballenced parentheses?
Is the lexer able to read past newlines to find it?

  $ reason $TESTDIR/reason_misbalenced_splice_close
  Fatal error: exception Regex_parser__Lexer.SyntaxError("Unexpected char: )")
  (Failure "TLM error in parser")
  Error: Error while running external preprocessor
  
What about extra open parens?

  $ reason $TESTDIR/reason_misbalenced_splice_open
  Parsing.Parse_error
  Error: Error while running external preprocessor
  
