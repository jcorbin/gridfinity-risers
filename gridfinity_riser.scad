include <vector76/gridfinity_modules.scad>

include <BOSL2/std.scad>
include <BOSL2/joiners.scad>

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

// Optionally generate a standalone baseplate; default is to generate a stackable module.
base = false;

// Optionally enable rabbit clip sockets in baseplate mode.
// These clips allow adjacent baseplates to be clipped together to form a larger strucure.
//
// NOTE: when generating clip sockets, a double rabbit clip object is generated alongside the baseplate;
// suggested workflow is to split the generated STL apart into objects in your slicer,
// then duplicate the clip as many times as desired.
//
// NOTE: suggested slicer settings for the clip (at least what worked for me):
//       2 wall loops, no top/bottom layers, 0% infill.
//       Basically the clips should generate as pure/only wall loops.
base_clips = true;
base_clip_length = 2 * 7;
base_clip_width = 2 * 7;
base_clip_depth = 3;
base_clip_snap = 0.75;
base_clip_thick = 1.6;
base_clip_compress = 0.2;

// Optionally carve pockets for rubber feet underneath the standalone baseplate.
// These default are for 6x2mm rubber feet, which seemd a nice rhyme with the magnet metrics.
// Unlink magnets however, these are only barely recessed to help them stay in place.
//
// NOTE: set base_feet_diameter to 0 to disable.
base_feet_every = 2;
base_feet_diameter = 6.5;
base_feet_depth = 0.5;

tunnel_block(width, depth, height, size=tunnel_size, magnet_diameter=magnets ? 6.5 : 0, base=base);

if (base && base_clips) {
  fwd(21+base_clip_length*1.5) right(21) up(2)
  rabbit_clip(
    type="double",
    length=base_clip_length,
    width=base_clip_width,
    snap=base_clip_snap,
    thickness=base_clip_thick,
    depth=base_clip_depth,
    compression=base_clip_compress
  );
}

module tunnel_block(num_x, num_y, num_z, size=3, magnet_diameter=6.5, base=false, center=false) {
  height = num_z * gridfinity_zpitch;

  corner_radius = 3.75;
  eps = 0.1;

  // frame metrics adapted from frame_plain() but with corner meticis reconciled with grid_block()
  frame_height = (base ? num_z * gridfinity_zpitch : 0) + 5;
  frame_lift = base ? 0 : height - 0.6;
  frame_outer_size = gridfinity_pitch - gridfinity_clearance;  // typically 41.5
  frame_corner_position = frame_outer_size/2 - corner_radius;
  total_height = frame_lift + frame_height;

  magnet_position = min(gridfinity_pitch/2-8, gridfinity_pitch/2-4-magnet_diameter/2);
  magnet_thickness = 2.4;
  magnet_margin = magnet_diameter > 0 ? (gridfinity_pitch/2 - magnet_position + magnet_diameter/4) : 0;

  feet_position = min(gridfinity_pitch/2-8, gridfinity_pitch/2-4-base_feet_diameter/2);

  xy_tunnel_width = min(size, floor(gridfinity_pitch / gridfinity_zpitch));
  z_tunnel_width = min(size, floor((gridfinity_pitch - 2*magnet_margin) / gridfinity_zpitch));
  tunnel_height = min(size,
    // tunnel size bigger than 3u starts to slightly undercut magnet holes, needs more headroom
    magnet_diameter > 0 && size > 3 ? num_z-2 : num_z-1);

  translate( center ? [-(num_x-1)*gridfinity_pitch/2, -(num_y-1)*gridfinity_pitch/2, 0] : [0, 0, 0] )
  difference() {

    union() {
      // use a grid block body if not generating a standalone baseplate
      if (!base) {
        grid_block(num_x, num_y, num_z, screw_depth=0);
      }

      // top frame body
      translate([0, 0, frame_lift])
      hull()
        cornercopy(frame_corner_position, num_x, num_y)
        cylinder(r=corner_radius, h=frame_height, $fn=32);
    }

    // top frame cell cutouts
    translate([0, 0, base ? num_z * gridfinity_zpitch : frame_lift])
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

    if (base) {

      // interconnect clip sockets
      if (base_clips) {
        copy_grid_perim(num_x, num_y)
          up(2 + 3/2) rabbit_clip(
            type="socket",
            length=base_clip_length,
            width=base_clip_width,
            snap=base_clip_snap,
            thickness=base_clip_thick,
            depth=base_clip_depth,
            compression=base_clip_compress,
            orient=FRONT);
      }

      // feet pockets
      if (base_feet_diameter > 0) {
        copy_grid_feet(num_x, num_y, every=base_feet_every)
          cylinder(d=base_feet_diameter, h=2*base_feet_depth+eps, $fn=48);
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

module copy_grid_feet(num_x, num_y, every = 3) {
  every2 = is_list(every) ? every : [every, every];
  every_x = num_x % every2[0] == 1 && every2[0] > 1 ? every2[0] - 1 : every2[0];
  every_y = num_y % every2[1] == 1 && every2[1] > 1 ? every2[1] - 1 : every2[1];
  for (xi = [0 : every_x : num_x+1])
  for (yi = [0 : every_y : num_y+1])
  {
    translate([
      gridfinity_pitch * (xi - 0.5) + nudge(xi, gridfinity_pitch/6, num_x),
      gridfinity_pitch * (yi - 0.5) + nudge(yi, gridfinity_pitch/6, num_y),
      0
    ]) children();
  }
}

function nudge(i, by, last) = i == 0 ? by : i == last ? -by : 0;

module copy_grid_perim(num_x, num_y) {
  for (i = [1:num_y-1])
    translate([-0.5 * gridfinity_pitch, (i - 0.5) * gridfinity_pitch, 0])
    rotate([0, 0, 90])
      children();
  for (i = [1:num_y-1])
    translate([(num_x - 0.5) * gridfinity_pitch, (i - 0.5) * gridfinity_pitch, 0])
    rotate([0, 0, -90])
      children();
  for (i = [1:num_x-1])
    translate([(i - 0.5) * gridfinity_pitch, -0.5 * gridfinity_pitch, 0])
    rotate([0, 0, 180])
      children();
  for (i = [1:num_x-1])
    translate([(i - 0.5) * gridfinity_pitch, (num_y - 0.5) * gridfinity_pitch, 0])
      children();
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

  if (height_mm > 0) {
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
