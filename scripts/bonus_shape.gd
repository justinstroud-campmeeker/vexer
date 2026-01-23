extends Area2D

signal hit(points: int)

@onready var shape_line: Line2D = $ShapeLine
@onready var lifetime_timer: Timer = $LifetimeTimer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

const SPIN_SPEED := 2.0
const GROW_DURATION := 0.5
const LIFETIME_MIN := 3.0
const LIFETIME_MAX := 6.0
const SHAPE_SIZE_MIN := 40.0
const SHAPE_SIZE_MAX := 80.0
const POINTS_MIN := 50   # Points for largest shape
const POINTS_MAX := 250  # Points for smallest shape

var shape_color: Color
var shape_size: float
var point_value: int
var vertices: PackedVector2Array = []
var current_scale: float = 0.0
var is_growing: bool = true
var is_exploding: bool = false
var explosion_lines: Array[Line2D] = []
var explosion_velocities: Array[Vector2] = []
var explosion_rotations: Array[float] = []
var explosion_colors: Array[Color] = []

func _ready() -> void:
	shape_color = _random_color()
	shape_size = randf_range(SHAPE_SIZE_MIN, SHAPE_SIZE_MAX)

	# Calculate points: smaller shapes = more points
	var size_ratio := (shape_size - SHAPE_SIZE_MIN) / (SHAPE_SIZE_MAX - SHAPE_SIZE_MIN)
	point_value = int(lerpf(POINTS_MAX, POINTS_MIN, size_ratio))

	_generate_shape()
	_setup_collision()

	lifetime_timer.wait_time = randf_range(LIFETIME_MIN, LIFETIME_MAX)
	lifetime_timer.one_shot = true
	lifetime_timer.timeout.connect(_on_lifetime_ended)
	lifetime_timer.start()

	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if is_exploding:
		_update_explosion(delta)
		return

	# Grow in effect
	if is_growing:
		current_scale += delta / GROW_DURATION
		if current_scale >= 1.0:
			current_scale = 1.0
			is_growing = false

	# Spin
	rotation += SPIN_SPEED * delta

	# Update visual scale
	shape_line.scale = Vector2.ONE * current_scale

func _generate_shape() -> void:
	var sides := randi_range(3, 6)  # Triangle to hexagon
	vertices.clear()

	for i in range(sides):
		var angle := (float(i) / sides) * TAU - PI / 2
		var point := Vector2(cos(angle), sin(angle)) * shape_size
		vertices.append(point)

	_draw_shape()

func _draw_shape() -> void:
	shape_line.clear_points()
	shape_line.default_color = shape_color
	shape_line.width = 2.0
	shape_line.antialiased = true

	for point in vertices:
		shape_line.add_point(point)
	# Close the shape
	if vertices.size() > 0:
		shape_line.add_point(vertices[0])

func _setup_collision() -> void:
	var circle := CircleShape2D.new()
	circle.radius = shape_size
	collision_shape.shape = circle

func _random_color() -> Color:
	# Exclude red (balls) and green (player line)
	var colors := [
		Color.CYAN,
		Color.MAGENTA,
		Color.YELLOW,
		Color.ORANGE,
		Color.PURPLE,
		Color.DEEP_SKY_BLUE,
		Color.HOT_PINK,
	]
	return colors[randi() % colors.size()]

func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D and not is_exploding:  # Hit by a ball
		hit.emit(point_value)
		_spawn_score_popup()
		_start_explosion()

func _spawn_score_popup() -> void:
	var popup := Node2D.new()
	popup.set_script(preload("res://scripts/score_popup.gd"))
	popup.position = global_position
	get_tree().current_scene.add_child(popup)
	popup.setup(point_value, shape_color)

func _on_lifetime_ended() -> void:
	if not is_exploding:
		queue_free()

func explode_no_points() -> void:
	# Trigger explosion without awarding points (called when ball is lost)
	if not is_exploding:
		_start_explosion()

func _start_explosion() -> void:
	is_exploding = true
	shape_line.visible = false
	collision_shape.set_deferred("disabled", true)

	var all_colors := [
		Color.CYAN,
		Color.MAGENTA,
		Color.YELLOW,
		Color.ORANGE,
		Color.PURPLE,
		Color.DEEP_SKY_BLUE,
		Color.HOT_PINK,
		Color.LIME,
		Color.CORAL,
		Color.GOLD,
	]

	# Create exploding line segments - multiple fragments per edge
	for i in range(vertices.size()):
		var start := vertices[i]
		var end := vertices[(i + 1) % vertices.size()]

		# Split each edge into 2-3 fragments
		var fragments := randi_range(2, 3)
		for f in range(fragments):
			var t1 := float(f) / fragments
			var t2 := float(f + 1) / fragments
			var frag_start := start.lerp(end, t1)
			var frag_end := start.lerp(end, t2)

			var line := Line2D.new()
			line.add_point(frag_start - (frag_start + frag_end) / 2)
			line.add_point(frag_end - (frag_start + frag_end) / 2)
			line.position = (frag_start + frag_end) / 2

			# Random color for each fragment
			var frag_color: Color = all_colors[randi() % all_colors.size()]
			line.default_color = frag_color
			explosion_colors.append(frag_color)

			line.width = 4.0  # Start thicker
			line.antialiased = true
			add_child(line)
			explosion_lines.append(line)

			# More dramatic outward velocity
			var midpoint := (frag_start + frag_end) / 2
			var base_velocity := midpoint.normalized() * randf_range(250, 450)
			var random_offset := Vector2(randf_range(-100, 100), randf_range(-100, 100))
			explosion_velocities.append(base_velocity + random_offset)

			# Add rotation speed
			explosion_rotations.append(randf_range(-15, 15))

func _update_explosion(delta: float) -> void:
	var all_faded := true

	for i in range(explosion_lines.size()):
		var line := explosion_lines[i]
		var velocity := explosion_velocities[i]
		var rot_speed := explosion_rotations[i]
		var base_color := explosion_colors[i]

		# Move line outward
		line.position += velocity * delta

		# Rotate the fragment
		line.rotation += rot_speed * delta

		# Fade out slower for more dramatic effect
		var current_alpha := line.default_color.a
		current_alpha -= delta * 1.2
		if current_alpha > 0:
			all_faded = false
			line.default_color = Color(base_color.r, base_color.g, base_color.b, current_alpha)
			# Shrink width as it fades
			line.width = 4.0 * current_alpha
		else:
			line.default_color.a = 0

	if all_faded:
		queue_free()
