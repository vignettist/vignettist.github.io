#!/bin/bash

for i in `seq 0 19`;
do
	echo $i
	montage $i/* -tile 10x1 -geometry +0+0 $i.jpg
done
