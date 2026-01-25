extends Node2D

const ZOOM_DURATION := 0.25
const HOLD_DURATION := 0.4
const FADE_DURATION := 0.5
const FLOAT_SPEED := 50.0
const SCALE_START := 0.2
const SCALE_PEAK := 1.8
const SCALE_END := 2.2
const FONT_SIZE := 36.0

var lifetime: float = 0.0
var phase: int = 0  # 0=zoom in, 1=hold, 2=fade out
var text_container: Node2D
var base_color: Color

func _ready() -> void:
	scale = Vector2.ONE * SCALE_START

func setup(points: int, color: Color) -> void:
	base_color = color
	var text := "+" + str(points)
	text_container = VectorFont.create_text(text, FONT_SIZE, color, 4.0)
	# Center the text
	var width := VectorFont.get_text_width(text, FONT_SIZE)
	var height := FONT_SIZE
	text_container.position = Vector2(-width / 2.0, -height / 2.0)
	add_child(text_container)

func _process(delta: float) -> void:
	lifetime += delta

	# Float upward (slower during zoom, faster during fade)
	var float_mult := 0.3 if phase == 0 else 1.0
	position.y -= FLOAT_SPEED * float_mult * delta

	match phase:
		0:  # Zoom in with elastic bounce
			if lifetime >= ZOOM_DURATION:
				lifetime = 0.0
				phase = 1
				scale = Vector2.ONE * SCALE_PEAK
			else:
				var t := lifetime / ZOOM_DURATION
				var elastic_t := _elastic_out(t)
				var current_scale := lerpf(SCALE_START, SCALE_PEAK, elastic_t)
				scale = Vector2.ONE * current_scale

		1:  # Hold
			if lifetime >= HOLD_DURATION:
				lifetime = 0.0
				phase = 2

		2:  # Fade out while still scaling up
			if lifetime >= FADE_DURATION:
				queue_free()
				return

			var t := lifetime / FADE_DURATION
			var alpha := 1.0 - t
			var current_scale := lerpf(SCALE_PEAK, SCALE_END, t)
			scale = Vector2.ONE * current_scale
			_set_alpha(text_container, alpha)

func _elastic_out(t: float) -> float:
	if t == 0.0:
		return 0.0
	if t == 1.0:
		return 1.0
	var p := 0.4
	var s := p / 4.0
	return pow(2.0, -10.0 * t) * sin((t - s) * TAU / p) + 1.0

func _set_alpha(node: Node, alpha: float) -> void:
	for child in node.get_children():
		if child is Line2D:
			var line := child as Line2D
			var color: Color = line.default_color
			line.default_color = Color(color.r, color.g, color.b, alpha)
		elif child is Node2D:
			_set_alpha(child, alpha)
