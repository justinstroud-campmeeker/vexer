extends RigidBody2D

signal scored(points: int)
signal hit_player_line
signal hit_wall(wall_name: String)

@onready var circle: Line2D = $Circle
@onready var trail_container: Node2D = $TrailContainer
@onready var score_timer: Timer = $ScoreTimer

const BALL_RADIUS := 15.0
const SCORE_INTERVAL := 1.0
const POINTS_PER_TICK := 10
const BASE_TRAIL_COUNT := 8
const MAX_TRAIL_COUNT := 25
const SPEED_TRAIL_MULTIPLIER := 0.03
const TRAIL_SPACING := 0.016
const SPEED_INCREASE_RATE := 0.02  # Speed multiplier increase per second
const MAX_SPEED_MULTIPLIER := 3.0
const THROB_DURATION := 0.15
const THROB_WIDTH := 7.0
const NORMAL_WIDTH := 3.0

var trail_positions: Array[Vector2] = []
var trail_circles: Array[Line2D] = []
var time_alive: float = 0.0
var trail_timer: float = 0.0
var speed_multiplier: float = 1.0
var throb_timer: float = 0.0
var is_throbbing: bool = false
var bodies_in_contact: Array = []

func _ready() -> void:
	_draw_circle()
	_setup_trail_circles()
	score_timer.wait_time = SCORE_INTERVAL
	score_timer.timeout.connect(_on_score_tick)
	score_timer.start()

	# Enable contact monitoring
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
	time_alive += delta
	trail_timer += delta

	# Increase speed over time
	speed_multiplier = minf(1.0 + time_alive * SPEED_INCREASE_RATE, MAX_SPEED_MULTIPLIER)
	_apply_speed_boost(delta)

	# Capture position at intervals
	if trail_timer >= TRAIL_SPACING:
		trail_timer = 0.0
		_capture_trail_position()

	_update_trail()
	_update_throb(delta)

func _apply_speed_boost(delta: float) -> void:
	# Gradually boost velocity based on time alive
	if linear_velocity.length() > 10:  # Only if moving
		var target_speed := linear_velocity.length() * speed_multiplier
		var current_speed := linear_velocity.length()
		if current_speed < target_speed:
			var boost := (target_speed - current_speed) * delta * 2.0
			linear_velocity = linear_velocity.normalized() * (current_speed + boost)

func _draw_circle() -> void:
	circle.clear_points()
	circle.default_color = Color.RED
	circle.width = NORMAL_WIDTH
	circle.antialiased = true

	var segments := 24
	for i in range(segments + 1):
		var angle := (float(i) / segments) * TAU
		var point := Vector2(cos(angle), sin(angle)) * BALL_RADIUS
		circle.add_point(point)

func _setup_trail_circles() -> void:
	for i in range(MAX_TRAIL_COUNT):
		var trail_circle := Line2D.new()
		trail_circle.width = NORMAL_WIDTH
		trail_circle.antialiased = true
		trail_circle.visible = false

		var segments := 24
		for j in range(segments + 1):
			var angle := (float(j) / segments) * TAU
			var point := Vector2(cos(angle), sin(angle)) * BALL_RADIUS
			trail_circle.add_point(point)

		trail_container.add_child(trail_circle)
		trail_circles.append(trail_circle)

func _capture_trail_position() -> void:
	trail_positions.insert(0, global_position)

	var speed := linear_velocity.length()
	var trail_count := int(BASE_TRAIL_COUNT + speed * SPEED_TRAIL_MULTIPLIER)
	trail_count = clampi(trail_count, BASE_TRAIL_COUNT, MAX_TRAIL_COUNT)

	if trail_positions.size() > trail_count:
		trail_positions.resize(trail_count)

func _update_trail() -> void:
	var speed := linear_velocity.length()
	var active_trail_count := int(BASE_TRAIL_COUNT + speed * SPEED_TRAIL_MULTIPLIER)
	active_trail_count = clampi(active_trail_count, BASE_TRAIL_COUNT, MAX_TRAIL_COUNT)

	for i in range(trail_circles.size()):
		var trail_circle := trail_circles[i]

		if i < trail_positions.size() and i < active_trail_count:
			trail_circle.visible = true
			trail_circle.global_position = trail_positions[i]
			trail_circle.rotation = 0

			var alpha := 1.0 - (float(i + 1) / active_trail_count)
			alpha *= 0.6
			trail_circle.default_color = Color(1, 0, 0, alpha)
		else:
			trail_circle.visible = false

func _on_body_entered(body: Node) -> void:
	bodies_in_contact.append(body)
	# Check if it's the player line's static body
	if body.get_parent() and body.get_parent().name == "PlayerLine":
		_start_throb()
		hit_player_line.emit()
	# Check if it's a wall
	elif body.name in ["NorthWall", "SouthWall", "EastWall", "WestWall"]:
		hit_wall.emit(body.name)

func _on_body_exited(body: Node) -> void:
	bodies_in_contact.erase(body)

func _start_throb() -> void:
	is_throbbing = true
	throb_timer = THROB_DURATION

func _update_throb(delta: float) -> void:
	if is_throbbing:
		throb_timer -= delta
		if throb_timer <= 0:
			is_throbbing = false
			circle.width = NORMAL_WIDTH
			circle.default_color = Color.RED
		else:
			# Interpolate width and color for glow effect
			var t := throb_timer / THROB_DURATION
			circle.width = lerpf(NORMAL_WIDTH, THROB_WIDTH, t)
			# Glow toward white/bright
			var glow_color := Color.RED.lerp(Color(1, 0.7, 0.7), t)
			circle.default_color = glow_color

func _on_score_tick() -> void:
	scored.emit(POINTS_PER_TICK)

func get_time_alive() -> float:
	return time_alive
