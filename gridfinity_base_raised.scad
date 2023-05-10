include <vector76/gridfinity_modules.scad>
include <BOSL2/std.scad>

xsize = 6;
ysize = 4;
zsize = 3;

base_raised(xsize, ysize, raise=zsize);

module base_raised(num_x, num_y, raise=1) {
  difference() {
    corner_radius = 3.75;
    corner_position = gridfinity_pitch/2-corner_radius;

    height = gridfinity_zpitch * raise;
    door_width = 42 - 2*corner_radius;
    frame_height = 4.4;

    hull()
      cornercopy(corner_position, num_x, num_y)
      translate([0, 0, -height])
      cylinder(r=corner_radius, h=frame_height + height, $fn=44);

    translate([0, 0, -0.01])
      render()
      gridcopy(num_x, num_y)
      pad_oversize(margins=1);

    translate([0, 0, -(height+0.5)])
      cutout(num_x, num_y, h=height+1, margins=1);


    for(i=[0:num_x-1])
      translate([i * gridfinity_pitch, (num_y/2 - 0.5) * gridfinity_pitch, 0])
        cuboid([door_width, (num_y+0.5)*gridfinity_pitch, height+1], rounding=corner_radius, edges=TOP, anchor=TOP);

    for(i=[0:num_y-1])
      translate([(num_x/2 - 0.5) * gridfinity_pitch, i * gridfinity_pitch, 0])
        cuboid([(num_x+0.5)*gridfinity_pitch, door_width, height+1], rounding=corner_radius, edges=TOP, anchor=TOP);
  }
}

module cutout(num_x=1, num_y=1, h=1, margins=0) {
  pad_corner_position = gridfinity_pitch/2 - 4; // must be 17 to be compatible
  bevel1_top = 0.8;     // z of top of bottom-most bevel (bottom of bevel is at z=0)
  bevel2_bottom = 2.6;  // z of bottom of second bevel
  bevel2_top = 5;       // z of top of second bevel
  bonus_ht = 0.2;       // extra height (and radius) on second bevel

  // female parts are a bit oversize for a nicer fit
  radialgap = margins ? 0.25 : 0;  // oversize cylinders for a bit of clearance

  gridcopy(num_x, num_y)
  hull() cornercopy(pad_corner_position, 1, 1) {
    if (sharp_corners) {
      cylsq(d=1.6+2*radialgap, h=1);
    }
    else {
      cylinder(d=1.6+2*radialgap, h=h, $fn=24);
    }
  }
}
