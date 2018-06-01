open Regex_example;

module Funct(A : { 
  module B = RegexNotation.RelitInternalDefn_regex 
}) = {
  notation $regex = 
