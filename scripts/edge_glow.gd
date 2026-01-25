extends Node2D

const FADE_DURATION := 1.5
const LINE_WIDTH := 3.0
const LINE_GAP := 8.0  # 4px visible gap between lines
const NUM_LINES := 5

var lifetime: float = 0.0
var lines: Array[Line2D] = []
var base_color: Color

func setup(edge: int, viewport_size: Vector2, color: Color) -> void:
	base_color = color

	# Create multiple thin lines with gaps for vector aesthetic
	for i in range(NUM_LINES):
		var line := Line2D.new()
		line.width = LINE_WIDTH
		line.default_color = Color(color.r, color.g, color.b, 0.9 - float(i) * 0.15)
		line.antialiased = true

		# Each line is offset by line width + gap
		var offset := float(i) * (LINE_WIDTH + LINE_GAP)

		# Position based on edge (0=North, 1=East, 2=South, 3=West)
		match edge:
			0:  # North (top)
				line.add_point(Vector2(0, offset))
				line.add_point(Vector2(viewport_size.x, offset))
			1:  # East (right)
				line.add_point(Vector2(viewport_size.x - offset, 0))
				line.add_point(Vector2(viewport_size.x - offset, viewport_size.y))
			2:  # South (bottom)
				line.add_point(Vector2(0, viewport_size.y - offset))
				line.add_point(Vector2(viewport_size.x, viewport_size.y - offset))
			3:  # West (left)
				line.add_point(Vector2(offset, 0))
				line.add_point(Vector2(offset, viewport_size.y))

		add_child(line)
		lines.append(line)

func _process(delta: float) -> void:
	lifetime += delta

	var t := lifetime / FADE_DURATION
	if t >= 1.0:
		queue_free()
		return

	# Fade out all lines
	for i in range(lines.size()):
		var line := lines[i]
		var base_alpha := 0.9 - float(i) * 0.15
		var alpha := base_alpha * (1.0 - t)
		line.default_color = Color(base_color.r, base_color.g, base_color.b, alpha)
