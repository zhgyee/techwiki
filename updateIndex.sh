#!/bin/bash
for i in `ls *.md`;
do
	a=${i%.md};
	echo -n "[$a]($a)     "
done
