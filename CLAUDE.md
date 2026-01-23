# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Vexer is a Godot 4.5 game project configured for mobile rendering. The project is in early development stages.

## Look and Feel

ALl graphics should be drawn vectors, no bitmaps, Any shapes should be hollow (no fill color.) 

Special effects (such as trails behind the ball and shapes exploding) follow the same aesthetic.

The player's line is green. The balls are red. The shapes that appear are any other color (randomized.)

## Gameplay

The player is in control of a line that they draw on the screen. They click a start point and drag the line to another point. As long as they hold the mouse button/finger down, they can move the second point. The first point always stays fixed.

At the start of a game, a ball drops from the top of the screen (NorthBody) and over time (with  increasing frequency) more balls drop. The player's score is calculated by how many balls they have onscreen at a time and for how long (each ball has a timer.) They lose a life if they either let a ball drop off the bottom of the screen or the balls pile up so much that they go above the north (top) boundary.

Over time, a handful of small geometric spinning shapes appear (by 'growing in') on screen. The player gets extra points for hitting these with a ball, although they disappear relatively quickly. When the olayer hits one, it 'explodes' (the lines tha make up the polygon shape fly outwards).

THe backgrouhd should be black. For now, everythinig is in TestScene. All gameplay elements should be modular so they are easy to implement. 

The balls should have some bounce to them, and appropriate physics are applied when they collide with the player's line.

The balls should bounce off the East and West boundaries.


## Running the Project

```bash
# Run from command line (requires Godot 4.5 in PATH)
godot --path /Volumes/1tb/godot/vexer --run

# Run a specific scene
godot --path /Volumes/1tb/godot/vexer scenes/testlevel.tscn

# Open in editor
godot --path /Volumes/1tb/godot/vexer --editor
```

## Directory Structure

- `scenes/` - Scene files (.tscn)
- `resources/` - Game assets and resources

## Godot Configuration

- Engine version: 4.5
- Rendering method: Mobile (optimized for mobile platforms)
- Default background: Black
