extends Node2D

@onready var line: Line2D = $Line2D
@onready var collision_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var static_body: StaticBody2D = $StaticBody2D

const NORMAL_WIDTH := 6.0
const THROB_WIDTH := 10.0
const THROB_DURATION := 0.15
const LINE_TIMEOUT := 5.0
const COLLISION_THICKNESS := 12.0  # Thicker than visual for reliable collision

var is_drawing: bool = false
var start_point: Vector2 = Vector2.ZERO
var end_point: Vector2 = Vector2.ZERO
var throb_timer: float = 0.0
var is_throbbing: bool = false
var line_timer: float = 0.0
var timer_display: Node2D = null
var timer_container: CanvasLayer = null

func _ready() -> void:
	line.default_color = Color.GREEN
	line.width = NORMAL_WIDTH
	line.antialiased = true
	_clear_line()
	_setup_timer_display()

func _setup_timer_display() -> void:
	timer_container = CanvasLayer.new()
	timer_container.layer = 15
	add_child(timer_container)

func _process(delta: float) -> void:
	_update_throb(delta)
	_update_line_timer(delta)

func _update_line_timer(delta: float) -> void:
	if is_drawing:
		line_timer += delta
		_update_timer_display()

		if line_timer >= LINE_TIMEOUT:
			_force_clear_line()
	else:
		if timer_display:
			timer_display.queue_free()
			timer_display = null

func _update_timer_display() -> void:
	var time_left := LINE_TIMEOUT - line_timer
	time_left = maxf(time_left, 0.0)

	# Remove old display
	if timer_display:
		timer_display.queue_free()

	# Create new display
	var time_text := str(ceili(time_left))

	# Color changes from green to yellow to red as time runs out
	var color: Color
	if time_left > 3.0:
		color = Color.GREEN
	elif time_left > 1.5:
		color = Color.YELLOW
	else:
		color = Color.RED

	timer_display = VectorFont.create_text(time_text, 40.0, color, 4.0)
	var text_width := VectorFont.get_text_width(time_text, 40.0)
	var viewport_size := get_viewport_rect().size
	timer_display.position = Vector2(viewport_size.x / 2.0 - text_width / 2.0, 20)
	timer_container.add_child(timer_display)

func _force_clear_line() -> void:
	is_drawing = false
	_clear_line()
	line_timer = 0.0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_start_drawing(event.position)
			else:
				_stop_drawing()

	elif event is InputEventMouseMotion and is_drawing:
		_update_end_point(event.position)

	# Touch support
	if event is InputEventScreenTouch:
		if event.pressed:
			_start_drawing(event.position)
		else:
			_stop_drawing()

	elif event is InputEventScreenDrag and is_drawing:
		_update_end_point(event.position)

func _start_drawing(pos: Vector2) -> void:
	is_drawing = true
	start_point = pos
	end_point = pos
	line_timer = 0.0
	_update_line()

func _stop_drawing() -> void:
	is_drawing = false
	line_timer = 0.0
	_clear_line()

func _update_end_point(pos: Vector2) -> void:
	end_point = pos
	_update_line()

func _update_line() -> void:
	line.clear_points()
	line.add_point(start_point)
	line.add_point(end_point)
	_update_collision()

func _clear_line() -> void:
	line.clear_points()
	collision_shape.shape = null

func _update_collision() -> void:
	var direction := end_point - start_point
	var length := direction.length()

	if length < 1.0:
		collision_shape.shape = null
		return

	# Use RectangleShape2D with thickness instead of infinitely thin SegmentShape2D
	# This prevents fast-moving balls from tunneling through the line
	var rect := RectangleShape2D.new()
	rect.size = Vector2(length, COLLISION_THICKNESS)

	# Position collision shape at the midpoint of the line
	var midpoint := (start_point + end_point) / 2.0
	collision_shape.position = midpoint

	# Rotate collision shape to align with the line direction
	collision_shape.rotation = direction.angle()

	collision_shape.shape = rect

func start_throb() -> void:
	is_throbbing = true
	throb_timer = THROB_DURATION

func _update_throb(delta: float) -> void:
	if is_throbbing:
		throb_timer -= delta
		if throb_timer <= 0:
			is_throbbing = false
			line.width = NORMAL_WIDTH
			line.default_color = Color.GREEN
		else:
			# Interpolate width and color for glow effect
			var t := throb_timer / THROB_DURATION
			line.width = lerpf(NORMAL_WIDTH, THROB_WIDTH, t)
			# Glow toward white/bright
			var glow_color := Color.GREEN.lerp(Color(0.7, 1, 0.7), t)
			line.default_color = glow_color
