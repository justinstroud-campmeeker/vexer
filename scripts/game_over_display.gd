extends Node2D

const TEXT := "GAME OVER!"
const FONT_SIZE := 70.0
const COLOR_CYCLE_SPEED := 8.0

var text_container: Node2D = null
var elapsed: float = 0.0

func _ready() -> void:
	text_container = VectorFont.create_text(TEXT, FONT_SIZE, Color.RED, 5.0)
	var text_width := VectorFont.get_text_width(TEXT, FONT_SIZE)
	var text_height := FONT_SIZE
	text_container.position = Vector2(-text_width / 2.0, -text_height / 2.0)
	add_child(text_container)

func _process(delta: float) -> void:
	elapsed += delta

	# Cycle between red and orange
	var t := (sin(elapsed * COLOR_CYCLE_SPEED) + 1.0) / 2.0
	var color := Color.RED.lerp(Color.ORANGE, t)

	_set_color(text_container, color)

func _set_color(node: Node, color: Color) -> void:
	for child in node.get_children():
		if child is Line2D:
			child.default_color = color
		elif child is Node2D:
			_set_color(child, color)
