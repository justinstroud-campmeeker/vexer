extends Control

var text_container: Node2D = null
var text_node: Node2D = null
var base_scale := 1.0
var pulse_amount := 0.2
var pulse_speed := 4.0
var time := 0.0
var min_display_time := 1.5
var elapsed_time := 0.0
var next_scene_ready := false
var text_width: float = 0.0
var text_height: float = 70.0

func _ready() -> void:
	_create_loading_text()
	_update_layout()
	get_tree().root.size_changed.connect(_on_viewport_resized)

	# Start loading the main menu in background
	ResourceLoader.load_threaded_request("res://scenes/main_menu.tscn")

func _process(delta: float) -> void:
	time += delta
	elapsed_time += delta

	# Pulsate the text size from center
	var pulse := sin(time * pulse_speed) * pulse_amount
	var new_scale := base_scale + pulse
	text_container.scale = Vector2(new_scale, new_scale)

	# Check if loading is complete
	var status := ResourceLoader.load_threaded_get_status("res://scenes/main_menu.tscn")
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		next_scene_ready = true

	# Transition after minimum display time and loading complete
	if next_scene_ready and elapsed_time >= min_display_time:
		var scene := ResourceLoader.load_threaded_get("res://scenes/main_menu.tscn")
		get_tree().change_scene_to_packed(scene)

func _on_viewport_resized() -> void:
	_update_layout()

func _update_layout() -> void:
	if text_container:
		var viewport_size := get_viewport_rect().size
		# Position container at screen center
		text_container.position = Vector2(viewport_size.x / 2.0, viewport_size.y / 2.0)

func _create_loading_text() -> void:
	text_width = VectorFont.get_text_width("LOADING", text_height)

	# Container at screen center, scales from its position
	text_container = Node2D.new()
	add_child(text_container)

	# Text offset so its center aligns with container origin
	text_node = VectorFont.create_text("LOADING", text_height, Color.CYAN, 4.0)
	text_node.position = Vector2(-text_width / 2.0, -text_height / 2.0)
	text_container.add_child(text_node)
