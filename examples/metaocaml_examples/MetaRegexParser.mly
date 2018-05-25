  %{
  open Regex
  %}
  %token DOT BAR STAR QMARK LPAREN RPAREN EOLIT
  %token <string> STR
  %token <RelitUtil.Segment.t> SPLICED_REGEX 
  %token <RelitUtil.Segment.t> SPLICED_STRING
  %left BAR
  %start <RelitUtil.ProtoExpr.t> start
  %type <Regex.t code> regex
  %%
  start:
    | e = regex; EOLIT { Print_code.close_code (e) }
    | EOLIT { Print_code.close_code .<Regex.Empty>. }
  regex:
    | DOT { .<Regex.AnyChar>. }
    | s = STR { .<Regex.Str s>. }
    | r1 = regex; r2 = regex 
      { .<(Regex.Seq .~r1) .~r2>. }
    | r1 = regex; BAR; r2 = regex 
      { .<(Regex.Or .~r1) .~r2>. }
    | r = regex; STAR { .<Regex.Star .~r>. }
    | r = regex; QMARK 
      { .<Regex.Or Regex.Empty .~r>. }
    | LPAREN; r = regex; RPAREN { r }
    | seg = SPLICED_REGEX 
      { .<(spliced .~seg) : Regex.t>. }
    | seg = SPLICED_STRING 
      { .<Regex.Str ((spliced .~seg) : Regex.t)>. }

