  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

The ppx should check to make sure that the splices are within bounds.

  $ caml $TESTDIR/invalid_splice_overlap
  Warning 10: this expression should have type unit.
  Relit_helper__Segment.InvalidSegmentation(_)
  Error: Error while running external preprocessor
  
