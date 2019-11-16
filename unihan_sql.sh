#!/bin/bash

# Extract Unihan_Variants.txt
curl --silent http://www.unicode.org/Public/UNIDATA/Unihan.zip | jar xv

# Convert Unihan_Variants.txt -> unihan-variants.txt
curl --silent https://raw.githubusercontent.com/osfans/rime-tool/master/tools/Unihan/variant.py | python3

# Create table and load data as is.
sqlite3 unihan.sqlite3 'create table unihan (node1 varchar, node2 varchar, primary key  (node1,node2))'
sed "s/^/insert into unihan values('/;s/\t/','/;s/$/');/" unihan-variant.txt | sqlite3 unihan.sqlite3

# Walk all edges and create tab separated file.
sqlite3 unihan.sqlite3 > unihan.tsv <<EOF
.separator \t( )\n
with
numtable as (
    select 1 as nthchar
    union all
    select nthchar+2 from numtable
        where nthchar < (select max(length(node2)) from unihan)
),
uh_expanded as (
    select node1, substr(node2,nthchar,1) as node2
	from numtable, unihan
        where length(substr(node2,nthchar,1)) = 1
),
uh_both as (
    select *           from uh_expanded
    union
    select node2,node1 from uh_expanded
),
uh_connected as (
    select * from uh_both
    union
    select b.node1, exp.node2
             from uh_both b, uh_connected exp
         	 where b.node2 = exp.node1
)
select node1,group_concat(node2,'|') from uh_connected
group by node1
EOF
