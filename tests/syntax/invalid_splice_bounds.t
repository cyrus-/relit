  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

The ppx should check to make sure that the splices are within bounds.

  $ reason $TESTDIR/invalid_splice_bounds
  Relit_helper__Segment.InvalidSegmentation(_)
  Error: Error while running external preprocessor
  
