extends Control

@onready var title_container: Node2D = $TitleContainer
@onready var scores_container: Node2D = $ScoresContainer
@onready var back_button_container: Node2D = $BackButtonContainer
@onready var fireworks: Node2D = $Fireworks

const MENU_BUTTON_SCRIPT := preload("res://scripts/menu_button.gd")

var back_button: Node2D = null

func _ready() -> void:
	_create_title()
	_create_scores()
	_create_back_button()
	_update_layout()
	get_tree().root.size_changed.connect(_on_viewport_resized)

func _on_viewport_resized() -> void:
	_update_layout()
	_update_fireworks_viewport()

func _update_layout() -> void:
	var viewport_size := get_viewport_rect().size
	title_container.position = Vector2(viewport_size.x / 2.0, viewport_size.y * 0.12)
	scores_container.position = Vector2(viewport_size.x / 2.0, viewport_size.y * 0.3)
	back_button_container.position = Vector2(viewport_size.x / 2.0, viewport_size.y - 70)

func _update_fireworks_viewport() -> void:
	if fireworks and fireworks.has_method("set_viewport_size"):
		fireworks.set_viewport_size(get_viewport_rect().size)

func _create_title() -> void:
	var title := VectorFont.create_text("HIGH SCORES", 50.0, Color.YELLOW, 4.0)
	var title_width := VectorFont.get_text_width("HIGH SCORES", 50.0)
	title.position.x = -title_width / 2.0
	title_container.add_child(title)

func _create_scores() -> void:
	var y_offset := 0.0
	var line_height := 80.0

	for diff in [GameState.Difficulty.EASY, GameState.Difficulty.MEDIUM, GameState.Difficulty.HARD]:
		var data: Dictionary = GameState.get_high_score(diff)
		var diff_name: String = GameState.get_difficulty_name(diff)

		# Difficulty color
		var diff_color: Color
		match diff:
			GameState.Difficulty.EASY: diff_color = Color.GREEN
			GameState.Difficulty.MEDIUM: diff_color = Color.YELLOW
			GameState.Difficulty.HARD: diff_color = Color.RED

		# Difficulty label
		var diff_label := VectorFont.create_text(diff_name, 50.0, diff_color, 3.0)
		var diff_width := VectorFont.get_text_width(diff_name, 50.0)
		diff_label.position = Vector2(-diff_width / 2.0, y_offset)
		scores_container.add_child(diff_label)

		y_offset += 55.0

		# Score and date
		var score_text: String
		if data["score"] > 0:
			score_text = str(data["score"]) + "  " + data["date"]
		else:
			score_text = "NO SCORE YET"

		var score_label := VectorFont.create_text(score_text, 50.0, Color.WHITE, 2.5)
		var score_width := VectorFont.get_text_width(score_text, 50.0)
		score_label.position = Vector2(-score_width / 2.0, y_offset)
		scores_container.add_child(score_label)

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
