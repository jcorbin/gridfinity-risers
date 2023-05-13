#!/usr/bin/env bash

set -e
set -x

cd $(dirname "$0")

width=1
depth=1
height=4

for width in 1 2 3 4 5 6; do
  for depth in 1 2 3 4 5; do
    openscad \
      ../gridfinity_riser.scad \
      -D width=${width} \
      -D depth=${depth} \
      -D height=${height} \
      -o tunnel_riser_${width}x${depth}x${height}.stl
  done
done

for width in 1 2; do
  for depth in 1 2; do
    for height in 8 12 16 18 20; do
      openscad \
        ../gridfinity_riser.scad \
        -D width=${width} \
        -D depth=${depth} \
        -D height=${height} \
        -o tunnel_tower_${width}x${depth}x${height}.stl
    done
  done
done
