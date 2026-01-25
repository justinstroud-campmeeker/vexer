extends Node2D

@onready var hud: CanvasLayer = $HUD
@onready var player_line: Node2D = $PlayerLine
@onready var ball_spawn_timer: Timer = $BallSpawnTimer
@onready var bonus_spawn_timer: Timer = $BonusSpawnTimer
@onready var balls_container: Node2D = $BallsContainer
@onready var shapes_container: Node2D = $ShapesContainer
@onready var north_wall: StaticBody2D = $NorthWall
@onready var south_wall: StaticBody2D = $SouthWall
@onready var east_wall: StaticBody2D = $EastWall
@onready var west_wall: StaticBody2D = $WestWall

const BALL_SCENE := preload("res://scenes/ball.tscn")
const BONUS_SHAPE_SCENE := preload("res://scenes/bonus_shape.tscn")
const EDGE_GLOW_SCRIPT := preload("res://scripts/edge_glow.gd")

const INITIAL_SPAWN_INTERVAL := 3.0
const MIN_SPAWN_INTERVAL := 0.5
const SPAWN_ACCELERATION := 0.95
const BONUS_SPAWN_INTERVAL := 5.0
const MIN_BONUS_SHAPES := 1
const MAX_BONUS_SHAPES := 5
const BOUNDARY_MARGIN := 50.0
const FLASH_DURATION := 0.15
const BALL_LOST_PENALTY := 50

@export var gravity_rotation_threshold := 1000  # Points needed to rotate gravity

# Gravity directions: 0=North(down), 1=East(left), 2=South(up), 3=West(right)
const GRAVITY_VECTORS := [
	Vector2(0, 1),    # North: gravity pulls down
	Vector2(-1, 0),   # East: gravity pulls left
	Vector2(0, -1),   # South: gravity pulls up
	Vector2(1, 0),    # West: gravity pulls right
]

var current_spawn_interval: float = INITIAL_SPAWN_INTERVAL
var is_game_active: bool = false
var viewport_size: Vector2
var screen_flash: ColorRect = null
var flash_timer: float = 0.0
var is_flashing: bool = false
var current_gravity_direction: int = 0
var last_gravity_threshold: int = 0
var gravity_mode: int = 2  # 0=none, 1=up/down, 2=full
var ball_count_container: CanvasLayer = null
var ball_count_display: Node2D = null

func _ready() -> void:
	viewport_size = get_viewport_rect().size

	_setup_screen_flash()
	_setup_ball_counter()
	_update_walls()

	# Connect HUD signals
	hud.score_changed.connect(_on_score_changed)
	hud.game_over.connect(_on_game_over)

	# Setup timers
	ball_spawn_timer.timeout.connect(_spawn_ball)
	bonus_spawn_timer.timeout.connect(_spawn_bonus_shape)

	# Connect viewport resize
	get_tree().root.size_changed.connect(_on_viewport_resized)

	# Start the game
	start_game()

func _setup_ball_counter() -> void:
	ball_count_container = CanvasLayer.new()
	ball_count_container.layer = 15
	add_child(ball_count_container)

func _update_ball_counter() -> void:
	if ball_count_display:
		ball_count_display.queue_free()

	var count := balls_container.get_child_count()
	var count_text := "BALLS: " + str(count)

	ball_count_display = VectorFont.create_text(count_text, 24.0, Color.WHITE, 3.0)
	var text_width := VectorFont.get_text_width(count_text, 24.0)
	ball_count_display.position = Vector2(viewport_size.x / 2.0 - text_width / 2.0, viewport_size.y - 50)
	ball_count_container.add_child(ball_count_display)

func _on_viewport_resized() -> void:
	viewport_size = get_viewport_rect().size
	_update_walls()
	_update_ball_counter()

func _update_walls() -> void:
	# Update wall positions based on viewport size
	south_wall.position = Vector2(0, viewport_size.y)
	east_wall.position = Vector2(viewport_size.x, 0)

func _process(delta: float) -> void:
	_update_flash(delta)
	_ensure_minimum_shapes()
	_check_balls_exit()
	_update_ball_counter()

func _setup_screen_flash() -> void:
	screen_flash = ColorRect.new()
	screen_flash.color = Color(1, 0.3, 0.3, 0)
	screen_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var flash_layer := CanvasLayer.new()
	flash_layer.layer = 20
	flash_layer.add_child(screen_flash)
	add_child(flash_layer)

func _trigger_flash() -> void:
	is_flashing = true
	flash_timer = FLASH_DURATION

func _spawn_edge_glow(edge: int, color: Color) -> void:
	var glow := Node2D.new()
	glow.set_script(EDGE_GLOW_SCRIPT)
	add_child(glow)
	glow.setup(edge, viewport_size, color)

func _get_spawn_edge() -> int:
	# Returns the edge balls spawn from based on gravity direction
	# 0=North, 1=East, 2=South, 3=West
	match current_gravity_direction:
		0: return 0  # Gravity down, spawn from North
		1: return 1  # Gravity left, spawn from East
		2: return 2  # Gravity up, spawn from South
		3: return 3  # Gravity right, spawn from West
	return 0

func _get_exit_edge() -> int:
	# Returns the edge balls exit from (opposite of spawn)
	return (_get_spawn_edge() + 2) % 4

func _update_flash(delta: float) -> void:
	if is_flashing:
		flash_timer -= delta
		if flash_timer <= 0:
			is_flashing = false
			screen_flash.color.a = 0
		else:
			var t := flash_timer / FLASH_DURATION
			screen_flash.color.a = t * 0.7

func _ensure_minimum_shapes() -> void:
	if not is_game_active:
		return
	var active_shapes := 0
	for child in shapes_container.get_children():
		if child.has_method("explode_no_points") and not child.is_exploding:
			active_shapes += 1
	if active_shapes < MIN_BONUS_SHAPES:
		_spawn_bonus_shape()

func start_game() -> void:
	is_game_active = true
	current_spawn_interval = INITIAL_SPAWN_INTERVAL * (1.0 / GameState.get_spawn_multiplier())
	current_gravity_direction = 0
	last_gravity_threshold = 0
	gravity_mode = GameState.get_gravity_mode()
	hud.reset()
	hud.set_gravity_direction(current_gravity_direction)
	_apply_gravity()

	# Clear existing balls/shapes
	for child in balls_container.get_children():
		child.queue_free()
	for child in shapes_container.get_children():
		child.queue_free()

	# Start spawning
	ball_spawn_timer.wait_time = current_spawn_interval
	ball_spawn_timer.start()
	bonus_spawn_timer.wait_time = BONUS_SPAWN_INTERVAL
	bonus_spawn_timer.start()

	# Spawn first ball and shape
	_spawn_ball()
	_spawn_bonus_shape()

func stop_game() -> void:
	is_game_active = false
	ball_spawn_timer.stop()
	bonus_spawn_timer.stop()

func _apply_gravity() -> void:
	# Set physics gravity based on direction
	var gravity_vector: Vector2 = GRAVITY_VECTORS[current_gravity_direction]
	PhysicsServer2D.area_set_param(
		get_viewport().find_world_2d().space,
		PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR,
		gravity_vector
	)
	_update_wall_collisions()

func _update_wall_collisions() -> void:
	# Enable all walls, then disable the exit wall
	north_wall.get_node("CollisionShape2D").disabled = false
	south_wall.get_node("CollisionShape2D").disabled = false
	east_wall.get_node("CollisionShape2D").disabled = false
	west_wall.get_node("CollisionShape2D").disabled = false

	# Disable the wall balls exit through
	match current_gravity_direction:
		0:  # Gravity down, exit at south
			south_wall.get_node("CollisionShape2D").disabled = true
		1:  # Gravity left, exit at west
			west_wall.get_node("CollisionShape2D").disabled = true
		2:  # Gravity up, exit at north
			north_wall.get_node("CollisionShape2D").disabled = true
		3:  # Gravity right, exit at east
			east_wall.get_node("CollisionShape2D").disabled = true

func _rotate_gravity() -> void:
	# gravity_mode: 0=none, 1=up/down only, 2=full rotation
	if gravity_mode == 0:
		return  # Easy mode: no gravity changes

	if gravity_mode == 1:
		# Medium mode: only toggle between 0 (down) and 2 (up)
		current_gravity_direction = 2 if current_gravity_direction == 0 else 0
	else:
		# Hard mode: full rotation
		current_gravity_direction = (current_gravity_direction + 1) % 4

	_apply_gravity()
	hud.set_gravity_direction(current_gravity_direction)

func _get_spawn_position() -> Vector2:
	# Spawn from the direction gravity is coming FROM
	match current_gravity_direction:
		0:  # Gravity down, spawn from top
			return Vector2(randf_range(BOUNDARY_MARGIN, viewport_size.x - BOUNDARY_MARGIN), -30)
		1:  # Gravity left, spawn from right
			return Vector2(viewport_size.x + 30, randf_range(BOUNDARY_MARGIN, viewport_size.y - BOUNDARY_MARGIN))
		2:  # Gravity up, spawn from bottom
			return Vector2(randf_range(BOUNDARY_MARGIN, viewport_size.x - BOUNDARY_MARGIN), viewport_size.y + 30)
		3:  # Gravity right, spawn from left
			return Vector2(-30, randf_range(BOUNDARY_MARGIN, viewport_size.y - BOUNDARY_MARGIN))
	return Vector2.ZERO

func _is_ball_exited(ball_pos: Vector2) -> bool:
	# Check if ball has exited in the direction gravity is pulling
	var margin := 50.0
	match current_gravity_direction:
		0:  # Gravity down, exit at bottom
			return ball_pos.y > viewport_size.y + margin
		1:  # Gravity left, exit at left
			return ball_pos.x < -margin
		2:  # Gravity up, exit at top
			return ball_pos.y < -margin
		3:  # Gravity right, exit at right
			return ball_pos.x > viewport_size.x + margin
	return false

func _check_balls_exit() -> void:
	if not is_game_active:
		return

	var balls_to_remove: Array[Node] = []
	for ball in balls_container.get_children():
		if _is_ball_exited(ball.global_position):
			balls_to_remove.append(ball)

	for ball in balls_to_remove:
		_on_ball_lost(ball)

func _spawn_ball() -> void:
	if not is_game_active:
		return

	var ball: RigidBody2D = BALL_SCENE.instantiate()
	ball.position = _get_spawn_position()

	ball.scored.connect(_on_ball_scored)
	ball.hit_player_line.connect(_on_ball_hit_player_line)
	ball.hit_wall.connect(_on_ball_hit_wall)

	balls_container.add_child(ball)

	# Green glow on spawn edge
	_spawn_edge_glow(_get_spawn_edge(), Color.GREEN)

	# Increase spawn rate
	current_spawn_interval *= SPAWN_ACCELERATION
	current_spawn_interval = max(current_spawn_interval, MIN_SPAWN_INTERVAL)
	ball_spawn_timer.wait_time = current_spawn_interval

func _spawn_bonus_shape() -> void:
	if not is_game_active:
		return

	if shapes_container.get_child_count() >= MAX_BONUS_SHAPES:
		return

	var shape: Area2D = BONUS_SHAPE_SCENE.instantiate()

	var margin := 100.0
	shape.position = Vector2(
		randf_range(margin, viewport_size.x - margin),
		randf_range(margin, viewport_size.y - margin)
	)

	shape.hit.connect(_on_bonus_hit)
	shapes_container.add_child(shape)

func _on_ball_scored(points: int) -> void:
	hud.add_score(points)

func _on_ball_hit_player_line() -> void:
	player_line.start_throb()

func _on_ball_hit_wall(wall_name: String) -> void:
	# Yellow glow on the wall that was hit
	var edge: int
	match wall_name:
		"NorthWall": edge = 0
		"EastWall": edge = 1
		"SouthWall": edge = 2
		"WestWall": edge = 3
		_: return
	_spawn_edge_glow(edge, Color.YELLOW)

func _on_ball_lost(ball: Node) -> void:
	# Red glow on exit edge
	_spawn_edge_glow(_get_exit_edge(), Color.RED)

	# Subtract score, track ball lost, flash screen, explode shapes
	hud.subtract_score(BALL_LOST_PENALTY)
	hud.add_ball_lost()
	_trigger_flash()
	_explode_all_shapes()
	ball.queue_free()

func _on_bonus_hit(points: int) -> void:
	hud.add_score(points)
	_remove_random_ball()

func _remove_random_ball() -> void:
	var balls := balls_container.get_children()
	if balls.size() <= 1:
		return  # Never go below 1 ball

	var random_index := randi() % balls.size()
	var ball_to_remove := balls[random_index]
	ball_to_remove.queue_free()

func _on_score_changed(new_score: int, _old_score: int) -> void:
	# Check for gravity rotation
	@warning_ignore("integer_division")
	var new_threshold := new_score / gravity_rotation_threshold
	if new_threshold > last_gravity_threshold:
		last_gravity_threshold = new_threshold
		_rotate_gravity()

func _on_game_over() -> void:
	_end_game()

func _explode_all_shapes() -> void:
	for child in shapes_container.get_children():
		if child.has_method("explode_no_points"):
			child.explode_no_points()

func _end_game() -> void:
	stop_game()
	var final_score: int = hud.get_score()
	print("Game Over! Final Score: ", final_score)

	# Check for high score
	var is_high_score := GameState.check_high_score(final_score)
	if is_high_score:
		print("New High Score!")

	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
