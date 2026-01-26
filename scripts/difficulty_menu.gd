extends Control

@onready var title_container: Node2D = $TitleContainer
@onready var buttons_container: Node2D = $ButtonsContainer

const MENU_BUTTON_SCRIPT := preload("res://scripts/menu_button.gd")

var easy_button: Node2D = null
var medium_button: Node2D = null
var hard_button: Node2D = null
var back_button: Node2D = null

func _ready() -> void:
	_create_title()
	_create_buttons()
	_update_layout()
	get_tree().root.size_changed.connect(_on_viewport_resized)

func _on_viewport_resized() -> void:
	_update_layout()

func _update_layout() -> void:
	var viewport_size := get_viewport_rect().size
	title_container.position = Vector2(viewport_size.x / 2.0, viewport_size.y * 0.15)
	buttons_container.position = Vector2(viewport_size.x / 2.0, viewport_size.y * 0.4)

func _create_title() -> void:
	var title := VectorFont.create_text("SELECT DIFFICULTY", 40.0, Color.CYAN, 3.5)
	var title_width := VectorFont.get_text_width("SELECT DIFFICULTY", 40.0)
	title.position.x = -title_width / 2.0
	title_container.add_child(title)

func _create_buttons() -> void:
	var button_spacing := 70.0
	var y_pos := 0.0

	# Easy button
	easy_button = Node2D.new()
	easy_button.set_script(MENU_BUTTON_SCRIPT)
	easy_button.text = "EASY"
	easy_button.font_size = 30.0
	easy_button.normal_color = Color.GREEN
	easy_button.hover_color = Color(0.5, 1, 0.5)
	easy_button.position.y = y_pos
	buttons_container.add_child(easy_button)
	easy_button.pressed.connect(_on_easy_pressed)
	y_pos += button_spacing

	# Medium button
	medium_button = Node2D.new()
	medium_button.set_script(MENU_BUTTON_SCRIPT)
	medium_button.text = "MEDIUM"
	medium_button.font_size = 30.0
	medium_button.normal_color = Color.YELLOW
	medium_button.hover_color = Color(1, 1, 0.5)
	medium_button.position.y = y_pos
	buttons_container.add_child(medium_button)
	medium_button.pressed.connect(_on_medium_pressed)
	y_pos += button_spacing

	# Hard button
	hard_button = Node2D.new()
	hard_button.set_script(MENU_BUTTON_SCRIPT)
	hard_button.text = "HARD"
	hard_button.font_size = 30.0
	hard_button.normal_color = Color.RED
	hard_button.hover_color = Color(1, 0.5, 0.5)
	hard_button.position.y = y_pos
	buttons_container.add_child(hard_button)
	hard_button.pressed.connect(_on_hard_pressed)
	y_pos += button_spacing + 30

	# Back button
	back_button = Node2D.new()
	back_button.set_script(MENU_BUTTON_SCRIPT)
	back_button.text = "BACK"
	back_button.font_size = 24.0
	back_button.normal_color = Color(0.6, 0.6, 0.6)
	back_button.hover_color = Color.WHITE
	back_button.position.y = y_pos
	buttons_container.add_child(back_button)
	back_button.pressed.connect(_on_back_pressed)

func _on_easy_pressed() -> void:
	GameState.difficulty = GameState.Difficulty.EASY
	SoundManager.play_new_game()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_medium_pressed() -> void:
	GameState.difficulty = GameState.Difficulty.MEDIUM
	SoundManager.play_new_game()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_hard_pressed() -> void:
	GameState.difficulty = GameState.Difficulty.HARD
	SoundManager.play_new_game()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
