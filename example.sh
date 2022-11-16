#!/bin/sh

i=0
ORIGINAL_ARGS=($*)
while [ $i -lt ${#ORIGINAL_ARGS[*]} ]; do
  arg=${ORIGINAL_ARGS[$i]}
  if [ $arg != "--delete" ]; then
    REDUCED_ARGS+=($arg)
  fi
  i=$((i + 1))
done
echo "REDUCED_ARGS = ${REDUCED_ARGS[*]}"
