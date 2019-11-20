#!/bin/bash
# grep wrapper to find kanji variants. 
# 1st arg should be filter string. No 'grep' option is allowed.
# May not work with a lot of regex special chars.
#set -x
uhgrep () 
{ 
    expanded="";
    for ((i=0; i<${#1}; i++))
    do
        expanded=${expanded}$(
	awk " \
	  /^\\${1:i:1}/ {printf(\"%s\",\$2);found=1;exit} \
          END         {if(!found) printf(\"%s\",\"${1:i:1}\")} \
	" ~/unihan.tsv
	);
    done;
    shift;
    grep -i --color=auto -E $expanded $*
}
uhgrep $*
