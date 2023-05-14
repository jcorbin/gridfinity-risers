include <vector76/gridfinity_modules.scad>

// Block height (7mm unit).
height = 4;

// Grid X cell count (42mm aka 6u relative to height).
width = 4;

// Grid Y cell count (42mm aka 6u relative to height).
depth = 3;

// Nominal tunnel size (7mm unit), will be clamped to available block space; 4u tunnels start to make sense in a 5u tall block.
tunnel_size = 3;

// If you don't need magnet attachments, 4u tunnels can be viable in even a 3u or 4u tall riser.
magnets = true;

tunnel_block(width, depth, height, size=tunnel_size, magnet_diameter=magnets ? 6.5 : 0);

module tunnel_block(num_x, num_y, num_z, size=3, magnet_diameter=6.5) {
  height = num_z * gridfinity_zpitch;

  corner_radius = 3.75;
  eps = 0.1;

  // frame metrics adapted from frame_plain() but with corner meticis reconciled with grid_block()
  frame_height = 5;
  frame_lift = height - 0.6;
  frame_outer_size = gridfinity_pitch - gridfinity_clearance;  // typically 41.5
  frame_corner_position = frame_outer_size/2 - corner_radius;
  total_height = frame_lift + frame_height;

  magnet_position = min(gridfinity_pitch/2-8, gridfinity_pitch/2-4-magnet_diameter/2);
  magnet_thickness = 2.4;
  magnet_margin = magnet_diameter > 0 ? (gridfinity_pitch/2 - magnet_position + magnet_diameter/4) : 0;

  xy_tunnel_width = min(size, floor(gridfinity_pitch / gridfinity_zpitch));
  z_tunnel_width = min(size, floor((gridfinity_pitch - 2*magnet_margin) / gridfinity_zpitch));
  tunnel_height = min(size,
    // tunnel size bigger than 3u starts to slightly undercut magnet holes, needs more headroom
    magnet_diameter > 0 && size > 3 ? num_z-2 : num_z-1);

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
    if (magnet_diameter > 0) {
      gridcopy(num_x, num_y) {
        cornercopy(magnet_position) {
          translate([0, 0, height-magnet_thickness])
          cylinder(d=magnet_diameter, h=magnet_thickness+eps, $fn=48);
        }
      }
    }

    tunnels(
      num_x, num_y, num_z,
      x_width = xy_tunnel_width,
      y_width = xy_tunnel_width,
      z_width = z_tunnel_width,
      height = tunnel_height,
      margin = 2.25,
      total_height=total_height);
  }
}

module tunnels(
  num_x, num_y, num_z,
  x_width=3, // 7mm unit ; bore width of X oriented tunnels
  y_width=3, // 7mm unit ; bore width of Y oriented tunnels
  z_width=3, // 7mm unit ; bore width of Z oriented tunnels
  height=3, // 7mm unit ; bore height of X and Y oriented tunnels
  margin=0, // mm ; Z lift for each layer of tunnels
  total_width=0, // mm ; override num_x bound
  total_depth=0, // mm ; override num_y bound
  total_height=0 // mm ; override num_z bound
) {
  x_width_mm = x_width * gridfinity_zpitch;
  y_width_mm = y_width * gridfinity_zpitch;
  z_width_mm = z_width * gridfinity_zpitch;
  height_mm = height * gridfinity_zpitch;

  total_x = total_width == 0 ? num_x * gridfinity_pitch : total_width;
  total_y = total_depth == 0 ? num_y * gridfinity_pitch : total_depth;
  total_z = total_height == 0 ? num_z * gridfinity_zpitch : total_height;

  every = ceil((height_mm + margin) / gridfinity_zpitch) * gridfinity_zpitch;
  lift = margin + every/2;

  for (layer = [0 : every : total_z - margin - height_mm]) {
    // X tunnels
    gridcopy(1, num_y)
    translate([-gridfinity_pitch/2-1, 0, layer + lift])
    rotate([0, 90, 0])
      tunnel(height_mm, x_width_mm, total_x + 2);

    // Y tunnels
    gridcopy(num_x, 1)
    translate([0, gridfinity_pitch * (num_y - 0.5)+1, layer + lift])
    rotate([90, 0, 0])
      tunnel(y_width_mm, height_mm, total_y + 2);
  }

  // Z tunnels
  gridcopy(num_x, num_y)
  translate([0, 0, -1])
    tunnel(z_width_mm, z_width_mm, total_z + 2);
}

module tunnel(xsize, ysize, h) {
  corner_radius = min(3.75, xsize/4, ysize/4);
  dx = xsize/2 - corner_radius;
  dy = ysize/2 - corner_radius;
  hull() {
    translate([-dx, -dy, 0])
      cylinder(r=corner_radius, h=h, $fn=48);
    translate([dx, -dy, 0])
      cylinder(r=corner_radius, h=h, $fn=48);
    translate([-dx, dy, 0])
      cylinder(r=corner_radius, h=h, $fn=48);
    translate([dx, dy, 0])
      cylinder(r=corner_radius, h=h, $fn=48);
  }
}
