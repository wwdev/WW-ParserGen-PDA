#!/bin/bash
bind_dir=$(basename "$0")
cd "$bin_dir"

../../../../bin/parser-gen-pda.pl --verbose --generate-op-pkg grammar.ebnf >/tmp/GrammarOps.pm
if [ $? = 0 ]; then
    mv -i /tmp/GrammarOps.pm GrammarOps.pm
fi

