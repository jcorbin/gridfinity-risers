include <BOSL2/std.scad>
include <BOSL2/screws.scad>

include <vector76/gridfinity_modules.scad>
use <gridfinity_riser.scad>

// Block height (7mm unit).
height = 1;

// Grid X cell count (42mm aka 6u relative to height).
width = 4;

// Grid Y cell count (42mm aka 6u relative to height).
depth = 4;

union() {
  feature_block(width, depth, height, feature=1.5);
  difference() {
    up(gridfinity_zpitch-1) screw("1/4-20", length=17);
    down(7) cube(25, 25, 7);
  }
}

// A tunnel block with a flat feature area in the middle.
// The X and Y dimension must both be odd or even.
// When size is odd, the feature will be centered on a grid wall intersection between 4 cells.
module feature_block(num_x, num_y, num_z, feature=1, magnet_diameter=6.5) {
  feat = is_list(feature) ? feature : [feature, feature];

  if (num_x % 2 == 0) {
    assert(num_y % 2 == 0, "x/y dimensions must be even or odd");
    difference() {
      tunnel_block(num_x, num_y, num_z, center=true);
      up(gridfinity_zpitch*2)
        cuboid([
          feat[0] * gridfinity_pitch,
          feat[1] * gridfinity_pitch,
          2*gridfinity_zpitch], rounding=3.75);
    }
  } else {
    assert(num_y % 2 == 1, "x/y dimensions must be even or odd");
    union() {
      difference() {
        tunnel_block(num_x, num_y, num_z, center=true);
        flat_void(feat[0], feat[1], num_z);
      }
      flat_grid_block(feat[0], feat[1], num_z, screw_depth=0);
    }
  }
}

module flat_grid_block(num_x, num_y, num_z, magnet_diameter=6.5, screw_depth=6) {
  difference() {
    grid_block(num_x, num_y, num_z,
      magnet_diameter=magnet_diameter,
      screw_depth=screw_depth,
      center=true);
    flat_void(num_x, num_y, num_z);
  }
}

module flat_void(num_x, num_y, num_z) {
  left(1 + gridfinity_pitch * (num_x/2))
  fwd(1 + gridfinity_pitch * (num_y/2))
  up(gridfinity_zpitch * num_z)
    cube([2 + gridfinity_pitch*num_x, 2 + gridfinity_pitch*num_y, 5]);
}
