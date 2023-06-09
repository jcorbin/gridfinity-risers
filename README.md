# Gridfinity Riser Modules

These are some riser modules useful for creating "cable basements" or otherwise
managing cable runs inside a gridfinity application.

Published STL models are published on [thangs](https://than.gs/m/853821)

Status:
- [x] working tunnel block for routing cables underneath a raised floor
- [x] tunnel towers can provide a sort of vertical conduit and/or support other
  modules; for example a AA battery charger stacked on top of a AA battery
  dispenser chute
- [x] tunnel sizes are reasonably flexible, clamping to available block space,
  and degrading to non-square rectangular tunnels when necessary
- [ ] consider switching the default tunnel size to 4u
- [ ] a baseplate variant of the tunnel block that is designed to sit well on a non-grid surface
  - maybe support edge pins to lock together multiple modules
  - maybe support cutting out voids for small devices embedded into the cable floor

## Tunnel Block

The primary module is a relatively solid/heavy block with tunnels cut along all 3 X/Y/Z axes for running cables.
The default tunnel size is 3u (21mm), which embeds well in a 4u-tall block.

![Tunnel Block 3x4x4](images/tunnel_riser_3x4x4.png)

## Tunnel Tower

When a tunnel block is scaled large enough in the Z axis, there will be
multiple layers of X/Y oriented tunnels, forming a tower.

With necessary margin, an `N` unit tall tunnel willl repeat every `N+1` units;
so the default 3u tunnel should repeat every 4u.

![Tunnel Tower 1x1x12](images/tunnel_tower_1x1x12.png)

## Tunnel Baseplate

This is a variant of the tunnel block with a flat bottom meant to be used as a baseplate:
- features rabbit clips and sockets to allow multiple basepaltes to be locked together
- features pockets for rubber feet, default setup for 6x2mm feet (0.5mm deep pockets)

These are designed for a desktop grid module that you don't want to accidentally slide around.

![Tunnel Baseplate (top view)](images/riser_base_3x3x4_top.png)
![Tunnel Baseplate (bottom view)](images/riser_base_3x3x4_bot.png)

## Hexagonal Walled Cups

Inspired by a question in the Gridfinity discord, this is a recreation of a
gridfinity cup with most of the wall material cut out by a hexagon grid.
This model was created similarly to the tunnerl riser above,
using [vector76] gridfinity mmodules and [bosl2] to manage the hexagaon window cutouts.

A potential use here would be a stackable bin, whose contents would still be
visble thru the side when stacked:
![Hex Cup 2x2x6](images/hex_cup_2x2x6.png)

Or a non-stacking pen cup:
![Hex Cup 1x1x12 (no lip)](images/hex_cup_1x1x12_nolip.png)

A similar cup can be seen in a picture uploaded by [ashleyi100 on thangs][ashleyi100]
which looks similar to this [non gridfinity box][hcomb_box] on printables.

## Raised Base

The initial design was a "legged table" based on [vector76] `frame_plain()` with extra height.

![Raised Base "leg table" 6x4x3](images/base_raised_6x4x3.png)

This version didn't feel great in practice,
as the legs would chatter/skip over the external surface,
allowing cables to jump/dislocate too easily.

[ashleyi100]: https://thangs.com/designer/ashleyi100
[bosl2]: https://github.com/revarbat/BOSL2
[hcomb_box]: https://www.printables.com/model/250845-honeycomb-pattern-box-with-label
[vector76]: https://github.com/vector76/gridfinity_openscad
