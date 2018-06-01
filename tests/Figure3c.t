  $ . $ORIGINAL_DIR/tests/helpers/caml.sh

Make sure Figure 3c works.

  $ reason $TESTDIR/Figure3c
  (String GC) ; (Or (Or (Or (String A) (String T)) (String G)) (String C)) ; (String GC) ; (Or (Or (Or (String A) (String T)) (String G)) (String C)) ; (Or (Or (Or (String A) (String T)) (String G)) (String C)) ; (String GC) ; (Or (Or (Or (String A) (String T)) (String G)) (String C)) ; (String GC)
