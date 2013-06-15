#!/bin/bash

outdir="sorted"
export LC_COLLATE="C"
mkdir -p "$outdir"
for src in "$@"; do
  out="$outdir/$( basename "$src" )"
  echo "$src -> $out"
  head -n 1 < "$src" > $out
  tail -n +2 < "$src" | sort -k2 -t, >> $out
done

# vim:ts=2:sw=2:sts=2:et:ft=sh

