#!/usr/bin/env bash

set -e
set -x

cd $(dirname "$0")

xsize=1
ysize=1
zsize=4

for xsize in 1 2 3 4 5 6; do
  for ysize in 1 2 3 4 5; do
    openscad \
      ../gridfinity_riser.scad \
      -D xsize=${xsize} \
      -D ysize=${ysize} \
      -D zsize=${zsize} \
      -o tunnel_riser_${xsize}x${ysize}x${zsize}.stl
  done
done

for xsize in 1 2; do
  for ysize in 1 2; do
    for zsize in 8 12 16 18 20; do
      openscad \
        ../gridfinity_riser.scad \
        -D xsize=${xsize} \
        -D ysize=${ysize} \
        -D zsize=${zsize} \
        -o tunnel_tower_${xsize}x${ysize}x${zsize}.stl
    done
  done
done
