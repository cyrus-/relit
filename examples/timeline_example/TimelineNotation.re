notation $timeline at Timeline.t {
  lexer Timeline_parser.Lexer
  parser Timeline_parser.Parser.start
  in package timeline_parser;
  dependencies = {
    module Timeline = Timeline;
  };
};
