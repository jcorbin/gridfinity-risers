include <vector76/gridfinity_modules.scad>

xsize = 4;
ysize = 3;
zsize = 4;

// size of cable routing tunnels ; TODO support non-square tunnels
tunnel_size = 3 * gridfinity_zpitch;

tunnel_block(xsize, ysize, zsize, size=tunnel_size);

module tunnel_block(num_x, num_y, num_z, size=0) {
  height = num_z * gridfinity_zpitch;
  lift = 2.25 + height/2;

  corner_radius = 3.75;
  magnet_od = 6.5;
  magnet_position = min(gridfinity_pitch/2-8, gridfinity_pitch/2-4-magnet_od/2);
  magnet_thickness = 2.4;
  eps = 0.1;

  // frame metrics adapted from frame_plain() but with corner meticis reconciled with grid_block()
  frame_height = 5;
  frame_lift = height - 0.6;
  frame_outer_size = gridfinity_pitch - gridfinity_clearance;  // typically 41.5
  frame_corner_position = frame_outer_size/2 - corner_radius;

  difference() {

    union() {
      // primary block body
      grid_block(num_x, num_y, num_z, screw_depth=0);

      // top frame body
      translate([0, 0, frame_lift])
      hull()
        cornercopy(frame_corner_position, num_x, num_y)
        cylinder(r=corner_radius, h=frame_height, $fn=32);
    }

    // top frame cell cutouts
    translate([0, 0, frame_lift])
      render()
      gridcopy(num_x, num_y)
      pad_oversize(margins=1);

    // top magnet holes
    gridcopy(num_x, num_y) {
      cornercopy(magnet_position) {
        translate([0, 0, gridfinity_zpitch*num_z-magnet_thickness])
        cylinder(d=magnet_od, h=magnet_thickness+eps, $fn=48);
      }
    }

    // X tunnels
    gridcopy(1, num_y)
    translate([-gridfinity_pitch/2-1, 0, lift])
    rotate([0, 90, 0])
      tunnel(size, gridfinity_pitch * num_x + 2);

    // Y tunnels
    gridcopy(num_x, 1)
    translate([0, gridfinity_pitch * (num_y - 0.5)+1, lift])
    rotate([90, 0, 0])
      tunnel(size, gridfinity_pitch * num_y + 2);

    // Z tunnels
    gridcopy(num_x, num_y)
    translate([0, 0, -1])
      tunnel(size, gridfinity_zpitch * num_z + 2);
  }
}

module tunnel(size, h) {
  corner_radius = min(3.75, size/4);
  displace = size/2 - corner_radius;
  hull() {
    translate([-displace, -displace, 0])
      cylinder(r=corner_radius, h=h, $fn=48);
    translate([displace, -displace, 0])
      cylinder(r=corner_radius, h=h, $fn=48);
    translate([-displace, displace, 0])
      cylinder(r=corner_radius, h=h, $fn=48);
    translate([displace, displace, 0])
      cylinder(r=corner_radius, h=h, $fn=48);
  }
}
