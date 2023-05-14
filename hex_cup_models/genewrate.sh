#!/usr/bin/env bash

set -e
set -x

cd $(dirname "$0")

width=1
depth=1
height=4

for width in 1 2 3; do
  for depth in 1 2 3; do
    for height in 4 6 12; do
      openscad \
        ../gridfinity_hex_cup.scad \
        -D width=${width} \
        -D depth=${depth} \
        -D height=${height} \
        -o hex_cup_${width}x${depth}x${height}.stl
    done
  done
done

width=1
depth=1

for height in 4 6 12; do
  openscad \
    ../gridfinity_hex_cup.scad \
    -D width=${width} \
    -D depth=${depth} \
    -D height=${height} \
    -D lip_style=none \
    -o hex_cup_${width}x${depth}x${height}_nolip.stl
done
