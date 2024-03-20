#!/bin/bash
test_file="../tests/test_practica2_"
for i in $(seq 6)
do
	test_file_py="${test_file}${i}.py"
	echo "$test_file_py"
	$($test_file_py) | tail -4
done
