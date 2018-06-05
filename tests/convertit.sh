cat $1.ml | refmt --parse ml --print re --interface false > $1.re
git rm $1.ml
git add $1.re

