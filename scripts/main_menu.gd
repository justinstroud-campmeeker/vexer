extends Control

@onready var title_container: Node2D = $TitleContainer
@onready var buttons_container: Node2D = $ButtonsContainer
@onready var footer_container: Node2D = $FooterContainer

const MENU_BUTTON_SCRIPT := preload("res://scripts/menu_button.gd")

var new_game_button: Node2D = null
var how_to_play_button: Node2D = null
var high_scores_button: Node2D = null

func _ready() -> void:
	_create_title()
	_create_buttons()
	_create_footer()
	_update_layout()
	get_tree().root.size_changed.connect(_on_viewport_resized)
	SoundManager.start_menu_music()

func _on_viewport_resized() -> void:
	_update_layout()

func _update_layout() -> void:
	var viewport_size := get_viewport_rect().size
	title_container.position = Vector2(viewport_size.x / 2.0, viewport_size.y * 0.2)
	buttons_container.position = Vector2(viewport_size.x / 2.0, viewport_size.y * 0.5)
	footer_container.position = Vector2(viewport_size.x / 2.0, viewport_size.y - 50)

func _create_title() -> void:
	var title := VectorFont.create_text("VEXER", 120.0, Color.YELLOW, 8.0)
	var title_width := VectorFont.get_text_width("VEXER", 120.0)
	title.position.x = -title_width / 2.0
	title_container.add_child(title)

func _create_buttons() -> void:
	# New Game button
	new_game_button = Node2D.new()
	new_game_button.set_script(MENU_BUTTON_SCRIPT)
	new_game_button.text = "NEW GAME"
	new_game_button.font_size = 30.0
	new_game_button.position.y = 0
	buttons_container.add_child(new_game_button)
	new_game_button.pressed.connect(_on_new_game_pressed)

	# How To Play button
	how_to_play_button = Node2D.new()
	how_to_play_button.set_script(MENU_BUTTON_SCRIPT)
	how_to_play_button.text = "HOW TO PLAY"
	how_to_play_button.font_size = 30.0
	how_to_play_button.position.y = 60
	buttons_container.add_child(how_to_play_button)
	how_to_play_button.pressed.connect(_on_how_to_play_pressed)

	# High Scores button
	high_scores_button = Node2D.new()
	high_scores_button.set_script(MENU_BUTTON_SCRIPT)
	high_scores_button.text = "HIGH SCORES"
	high_scores_button.font_size = 30.0
	high_scores_button.position.y = 120
	buttons_container.add_child(high_scores_button)
	high_scores_button.pressed.connect(_on_high_scores_pressed)

func _create_footer() -> void:
	var footer_text := "OVALHEAD LABS, 2025"
	var footer := VectorFont.create_text(footer_text, 16.0, Color(0.5, 0.5, 0.5), 2.0)
	var footer_width := VectorFont.get_text_width(footer_text, 16.0)
	footer.position.x = -footer_width / 2.0
	footer_container.add_child(footer)

func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/difficulty_menu.tscn")

func _on_how_to_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/how_to_play.tscn")

func _on_high_scores_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/high_scores.tscn")
