include <vector76/gridfinity_modules.scad>
use <vector76/gridfinity_cup_modules.scad>

include <BOSL2/std.scad>

// Block height (7mm unit).
height = 6;

// Grid X cell count (42mm aka 6u relative to height).
width = 2;

// Grid Y cell count (42mm aka 6u relative to height).
depth = 2;

// Hex cutout size in 7mm units.
// Make them bigger if planning pass larger objects (e.g. cables) through,
// or if the cup simply doesn't need to constrain smaller objects.
hex_size = 1;

// Whether to cut out hex cells whose center point is outside each wall cutout window.
// Can be useful for larger hex_size, but tends to create edge artifacts with small hex_size.
partial_hexes = false;

// Whether the cup should have magnet pockets.
magnets = true;

// Whether the cup should have magnet holes.
screws = false;

// What kind of lid the cup top should have:
// - "normal" and "reduced" allow for stacking
// - "none" can be used if you want more hexes and no stackability
lip_style = "normal";

hex_cup(
  width, depth, height,
  hex_size=hex_size,
  partial_hexes=partial_hexes,
  lip_style= lip_style,
  magnet_diameter = magnets ? 6.5 : 0,
  screw_depth = screws ? 6 : 0
);

module hex_cup(
  num_x, num_y, num_z,

  hex_size=1,
  partial_hexes = false,

  magnet_diameter=6.5,
  screw_depth=6,
  hole_overhang_remedy=false,

  floor_thickness=1.2,
  wall_thickness=0.95,
  efficient_floor=false,
  lip_style="normal",
  box_corner_attachments_only=false

) {

  hex_pitch = hex_size * gridfinity_zpitch;

  hex_wall = wall_thickness * 2;
  hex_extra = partial_hexes ? hex_pitch : 0;

  corner_radius = 3.75;
  eps = 0.01;

  x_outer_size = num_x * gridfinity_pitch - gridfinity_clearance;
  y_outer_size = num_y * gridfinity_pitch - gridfinity_clearance;
  z_outer_size = num_z * gridfinity_zpitch;

  floor_lift = 2;
  lip_height = lip_style == "none" ? 0 : lip_style == "reduced" ? 3 : 4;

  x_inner_size = x_outer_size - corner_radius * 2;
  y_inner_size = y_outer_size - corner_radius * 2;
  z_inner_size = z_outer_size - 5 - lip_height; // 5 for base
  z_inner_lift = floor_lift + (z_outer_size - z_inner_size)/2 - lip_height;

  difference() {

    center_vector76(num_x, num_y, num_z)
      grid_block(
        num_x, num_y, num_z,
        magnet_diameter=magnet_diameter,
        screw_depth=screw_depth,
        hole_overhang_remedy=hole_overhang_remedy,
        box_corner_attachments_only=box_corner_attachments_only
      );

    center_vector76(num_x, num_y, num_z)
      basic_cavity(
        num_x, num_y, num_z,
        fingerslide=false,
        magnet_diameter=magnet_diameter,
        screw_depth=screw_depth,
        floor_thickness=floor_thickness,
        wall_thickness=wall_thickness,
        efficient_floor=efficient_floor,
        lip_style=lip_style
      );

    // X axis aligned hex cutouts
    up(z_inner_lift) intersection() {
      cuboid(
        [x_outer_size+2, y_inner_size, z_inner_size],
        rounding=corner_radius,
        edges="X",
        $fn=32
      );

      left(y_outer_size/2+1)
      xrot(90)
      yrot(90)
      zrot(90)
        grid_copies(
          spacing=hex_pitch,
          stagger=true,
          inside=square(size=[z_inner_size + hex_extra, y_inner_size + hex_extra], center=true)
        )
          zrot(180/6)
          cylinder(h=y_outer_size+2, d=(hex_pitch - hex_wall/2)/cos(180/6) + eps, $fn=6);
    }

    // Y axis aligned hex cutouts
    up(z_inner_lift) intersection() {
      cuboid(
        [y_inner_size, x_outer_size+2, z_inner_size],
        rounding=corner_radius,
        edges="Y",
        $fn=32
      );

      back(y_outer_size/2+1)
      xrot(90)
      zrot(90)
        grid_copies(
          spacing=hex_pitch,
          stagger=true,
          inside=square(size=[z_inner_size + hex_extra, x_inner_size + hex_extra], center=true)
        )
          zrot(180/6)
          cylinder(h=y_outer_size+2, d=(hex_pitch - hex_wall/2)/cos(180/6) + eps, $fn=6);
    }

  }

}

// Origin fixup for using vector76 modules with bosl2
module center_vector76(num_x, num_y, num_z) {
  translate([
    (0.5 - num_x/2) * gridfinity_pitch,
    (0.5 - num_x/2) * gridfinity_pitch,
    (-num_z/2) * gridfinity_zpitch
  ]) children();
}
