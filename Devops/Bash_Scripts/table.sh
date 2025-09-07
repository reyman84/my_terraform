#!/bin/bash
# Script to print multiplication table using while loop

read -p "Enter table of " TAB

echo "Table of $TAB is"

i=1
while [ $i -le 10 ]
do
    echo "$i x $TAB = $((i * TAB))"
    sleep 2
    ((i++))
done
