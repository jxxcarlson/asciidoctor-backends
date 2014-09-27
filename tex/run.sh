#!/bin/sh
# Usage:  sh run.sh sample1
# Note: no .ad extension above

asciidoctor -r ./tex-converter.rb -b latex $1.ad -o $1.tex

