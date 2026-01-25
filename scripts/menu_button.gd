extends Node2D

signal pressed

@export var text: String = "BUTTON"
@export var font_size: float = 30.0
@export var normal_color: Color = Color.WHITE
@export var hover_color: Color = Color.CYAN
@export var line_width: float = 3.0

var text_node: Node2D = null
var is_hovered: bool = false
var click_area: Control = null

func _ready() -> void:
	_create_text()
	_create_click_area()

func _create_text() -> void:
	if text_node:
		text_node.queue_free()

	text_node = VectorFont.create_text(text, font_size, normal_color, line_width)

	# Center the text
	var text_width := VectorFont.get_text_width(text, font_size)
	text_node.position.x = -text_width / 2.0
	text_node.position.y = -font_size / 2.0

	add_child(text_node)

func _create_click_area() -> void:
	click_area = Control.new()
	var text_width := VectorFont.get_text_width(text, font_size)
	var padding := 20.0

	click_area.position = Vector2(-text_width / 2.0 - padding, -font_size / 2.0 - padding)
	click_area.custom_minimum_size = Vector2(text_width + padding * 2, font_size + padding * 2)
	click_area.size = click_area.custom_minimum_size

	click_area.mouse_entered.connect(_on_mouse_entered)
	click_area.mouse_exited.connect(_on_mouse_exited)
	click_area.gui_input.connect(_on_gui_input)

	add_child(click_area)

func _on_mouse_entered() -> void:
	is_hovered = true
	_update_color(hover_color)

func _on_mouse_exited() -> void:
	is_hovered = false
	_update_color(normal_color)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			pressed.emit()

func _update_color(color: Color) -> void:
	if text_node:
		for char_node in text_node.get_children():
			for line in char_node.get_children():
				if line is Line2D:
					line.default_color = color

func set_text(new_text: String) -> void:
	text = new_text
	if is_inside_tree():
		_create_text()
		if click_area:
			click_area.queue_free()
		_create_click_area()
