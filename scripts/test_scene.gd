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

const INITIAL_SPAWN_INTERVAL := 3.0
const MIN_SPAWN_INTERVAL := 0.5
const SPAWN_ACCELERATION := 0.95
const BONUS_SPAWN_INTERVAL := 5.0
const MIN_BONUS_SHAPES := 1
const MAX_BONUS_SHAPES := 5
const BOUNDARY_MARGIN := 50.0
const FLASH_DURATION := 0.15
const BALL_LOST_PENALTY := 50

@export var gravity_rotation_threshold := 200  # Points needed to rotate gravity

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

func _ready() -> void:
	viewport_size = get_viewport_rect().size

	_setup_screen_flash()

	# Connect HUD signals
	hud.score_changed.connect(_on_score_changed)
	hud.game_over.connect(_on_game_over)

	# Setup timers
	ball_spawn_timer.timeout.connect(_spawn_ball)
	bonus_spawn_timer.timeout.connect(_spawn_bonus_shape)

	# Start the game
	start_game()

func _process(delta: float) -> void:
	_update_flash(delta)
	_ensure_minimum_shapes()
	_check_balls_exit()

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
	current_spawn_interval = INITIAL_SPAWN_INTERVAL
	current_gravity_direction = 0
	last_gravity_threshold = 0
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
	var gravity_vector := GRAVITY_VECTORS[current_gravity_direction]
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

	balls_container.add_child(ball)

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

func _on_ball_lost(ball: Node) -> void:
	# Subtract score, flash screen, explode shapes
	hud.subtract_score(BALL_LOST_PENALTY)
	_trigger_flash()
	_explode_all_shapes()
	ball.queue_free()

func _on_bonus_hit(points: int) -> void:
	hud.add_score(points)

func _on_score_changed(new_score: int, old_score: int) -> void:
	# Check for gravity rotation
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

	await get_tree().create_timer(2.0).timeout
	start_game()
