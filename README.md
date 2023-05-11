# Gridfinity Riser Modules

These are some riser modules useful for creating "cable basements" or otherwise
managing cable runs inside a gridfinity application.

Currently there are two models available:

## Tunnel Block

The primary module is a relatively solid/heavy block with tunnels cut along all 3 X/Y/Z axes for running cables.
The default tunnel size is 21mm (half of the gridfinity 42mm cell size), which embeds well in a 4u-tall block.

![Tunnel Block 3x4x4](images/tunnel_riser_3x4x4.png)

This block works well enough that I'm already using it, but there are a few improvements that are still in mind:
- [ ] allow for non-square tunnels, to carve out more X/Y space, and reduce material cost further
- [ ] add an option for this block to just **be the baseplate**
  * maybe this is actually a separate module, descended from upstream `frame_plain()` instead of `grid_block()`
  * basically this would be a reprise of the original raised base / leg table, but with tunnels and a solid bottom

## Tunnel Tower

When a tunnel block is scaled large enough in the Z axis, there will be
multiple layers of X/Y oriented tunnels, forming a tower.

With the usual 21mm tunnel width, this works out to one tunnel every 4u
(with standard Gridfinity Z unit being 7mm).

![Tunnel Tower 1x1x12](images/tunnel_tower_1x1x12.png)

## Raised Base

The initial design was a "legged table" based on `frame_plain()` with extra height.

![Raised Base "leg table" 6x4x3](images/base_raised_6x4x3.png)

This version didn't feel great in practice,
as the legs would chatter/skip over the external surface,
allowing cables to jump/dislocate too easily.
