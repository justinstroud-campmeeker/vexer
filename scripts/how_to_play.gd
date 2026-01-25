extends Control

@onready var title_container: Node2D = $TitleContainer
@onready var content_container: Node2D = $ContentContainer
@onready var back_button_container: Node2D = $BackButtonContainer
@onready var grid_bg: ColorRect = $GridBackground

const MENU_BUTTON_SCRIPT := preload("res://scripts/menu_button.gd")

var back_button: Node2D = null

func _ready() -> void:
	_create_title()
	_create_content()
	_create_back_button()
	_update_layout()
	get_tree().root.size_changed.connect(_on_viewport_resized)

func _on_viewport_resized() -> void:
	_update_layout()

func _update_layout() -> void:
	var viewport_size := get_viewport_rect().size
	title_container.position = Vector2(viewport_size.x / 2.0, viewport_size.y * 0.1)
	content_container.position = Vector2(viewport_size.x / 2.0, viewport_size.y * 0.25)
	back_button_container.position = Vector2(viewport_size.x / 2.0, viewport_size.y - 70)

func _create_title() -> void:
	var title := VectorFont.create_text("HOW TO PLAY", 45.0, Color.CYAN, 4.0)
	var title_width := VectorFont.get_text_width("HOW TO PLAY", 45.0)
	title.position.x = -title_width / 2.0
	title_container.add_child(title)

func _create_content() -> void:
	var bullets: Array[String] = [
		"DRAW LINES TO DEFLECT BALLS",
		"KEEP BALLS IN PLAY TO SCORE",
		"LINES TIMEOUT AFTER 5 SECONDS",
		"HIT SHAPES FOR BONUS POINTS",
		"SMALLER SHAPES = MORE POINTS",
		"YOU HAVE 20 LIVES",
		"LOSE A LIFE WHEN A BALL ESCAPES",
		"GRAVITY SHIFTS AS YOU SCORE",
	]

	var y_offset := 0.0
	var line_height := 45.0

	for bullet: String in bullets:
		var text: String = "- " + bullet
		var label := VectorFont.create_text(text, 22.0, Color.WHITE, 2.5)
		var text_width := VectorFont.get_text_width(text, 22.0)
		label.position = Vector2(-text_width / 2.0, y_offset)
		content_container.add_child(label)
		y_offset += line_height

func _create_back_button() -> void:
	back_button = Node2D.new()
	back_button.set_script(MENU_BUTTON_SCRIPT)
	back_button.text = "BACK"
	back_button.font_size = 28.0
	back_button.normal_color = Color(0.7, 0.7, 0.7)
	back_button.hover_color = Color.WHITE
	back_button_container.add_child(back_button)
	back_button.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
