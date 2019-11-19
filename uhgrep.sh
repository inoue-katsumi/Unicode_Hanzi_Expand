#!/bin/bash
uhgrep () 
{ 
    expanded="";
    for ((i=0; i<${#1}; i++))
    do
        expanded=${expanded}$(awk "/^${1:i:1}/ {printf(\"%s\",\$2)}" ~/unihan.tsv);
    done;
    shift;
    grep -i --color=auto -E $expanded $*
}
uhgrep $*
