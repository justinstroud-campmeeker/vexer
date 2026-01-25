extends Node2D

const FLOAT_SPEED := 80.0
const FADE_DURATION := 1.0
const SCALE_START := 0.5
const SCALE_END := 1.2

var lifetime: float = 0.0
var text_container: Node2D

func _ready() -> void:
	scale = Vector2.ONE * SCALE_START

func setup(points: int, color: Color) -> void:
	var text := "+" + str(points)
	text_container = VectorFont.create_text(text, 20, color, 3.0)
	# Center the text
	var width := VectorFont.get_text_width(text, 20)
	text_container.position.x = -width / 2
	add_child(text_container)

func _process(delta: float) -> void:
	lifetime += delta

	# Float upward
	position.y -= FLOAT_SPEED * delta

	# Scale up
	var t := lifetime / FADE_DURATION
	var current_scale := lerpf(SCALE_START, SCALE_END, t)
	scale = Vector2.ONE * current_scale

	# Fade out
	var alpha := 1.0 - t
	if alpha <= 0:
		queue_free()
		return

	# Update alpha on all Line2D children
	_set_alpha(text_container, alpha)

func _set_alpha(node: Node, alpha: float) -> void:
	for child in node.get_children():
		if child is Line2D:
			var line := child as Line2D
			var color: Color = line.default_color
			line.default_color = Color(color.r, color.g, color.b, alpha)
		elif child is Node2D:
			_set_alpha(child, alpha)
