extends Node2D

const ZOOM_DURATION := 0.4
const HOLD_DURATION := 0.6
const FADE_DURATION := 0.3
const START_SCALE := 0.1
const END_SCALE := 1.5
const TEXT := "+1 LIFE!"
const FONT_SIZE := 60.0

var text_node: Node2D = null
var elapsed: float = 0.0
var phase: int = 0  # 0=zoom in, 1=hold, 2=fade out

func _ready() -> void:
	text_node = VectorFont.create_text(TEXT, FONT_SIZE, Color.GREEN, 5.0)
	var text_width := VectorFont.get_text_width(TEXT, FONT_SIZE)
	var text_height := FONT_SIZE
	text_node.position = Vector2(-text_width / 2.0, -text_height / 2.0)
	add_child(text_node)
	scale = Vector2.ONE * START_SCALE

func _process(delta: float) -> void:
	elapsed += delta

	match phase:
		0:  # Zoom in with bounce
			if elapsed >= ZOOM_DURATION:
				elapsed = 0.0
				phase = 1
				scale = Vector2.ONE * END_SCALE
			else:
				var t := elapsed / ZOOM_DURATION
				# Elastic ease out for dramatic zoom
				var elastic_t := _elastic_out(t)
				var current_scale := lerpf(START_SCALE, END_SCALE, elastic_t)
				scale = Vector2.ONE * current_scale

		1:  # Hold
			if elapsed >= HOLD_DURATION:
				elapsed = 0.0
				phase = 2

		2:  # Fade out
			if elapsed >= FADE_DURATION:
				# Clean up the CanvasLayer parent too
				var parent := get_parent()
				if parent is CanvasLayer:
					parent.queue_free()
				else:
					queue_free()
			else:
				var t := elapsed / FADE_DURATION
				modulate.a = 1.0 - t
				# Continue scaling up slightly while fading
				var fade_scale := END_SCALE + (t * 0.3)
				scale = Vector2.ONE * fade_scale

func _elastic_out(t: float) -> float:
	if t == 0.0:
		return 0.0
	if t == 1.0:
		return 1.0
	var p := 0.3
	var s := p / 4.0
	return pow(2.0, -10.0 * t) * sin((t - s) * TAU / p) + 1.0
