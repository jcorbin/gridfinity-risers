include <vector76/gridfinity_modules.scad>
include <BOSL2/std.scad>
include <BOSL2/screws.scad>

grid_block(3, 3, 1, screw_depth=0, center=true);
up(8) screw("1/4-20", length=13);
