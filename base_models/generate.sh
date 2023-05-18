#!/usr/bin/env bash

set -e

cd $(dirname "$0")

width=3
depth=3
height=4

for width in 3 4 5 6; do
  for depth in 3 4 5; do
    [ $depth -gt $width ] && continue
    openscad \
      ../gridfinity_riser.scad \
      -D base=true \
      -D base_clips=true \
      -D width=${width} \
      -D depth=${depth} \
      -D height=${height} \
      -o tunnel_base_${width}x${depth}x${height}_with_clip.stl
  done
done

height=1

for width in 3 4 5 6; do
  for depth in 3 4 5; do
    [ $depth -gt $width ] && continue
    openscad \
      ../gridfinity_riser.scad \
      -D base=true \
      -D base_clips=true \
      -D width=${width} \
      -D depth=${depth} \
      -D height=${height} \
      -o grid_base_${width}x${depth}_with_clip.stl
  done
done
