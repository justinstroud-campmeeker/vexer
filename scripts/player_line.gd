extends Node2D

@onready var line: Line2D = $Line2D
@onready var collision_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var static_body: StaticBody2D = $StaticBody2D

const NORMAL_WIDTH := 4.0
const THROB_WIDTH := 8.0
const THROB_DURATION := 0.15

var is_drawing: bool = false
var start_point: Vector2 = Vector2.ZERO
var end_point: Vector2 = Vector2.ZERO
var throb_timer: float = 0.0
var is_throbbing: bool = false

func _ready() -> void:
	line.default_color = Color.GREEN
	line.width = NORMAL_WIDTH
	line.antialiased = true
	_clear_line()

func _process(delta: float) -> void:
	_update_throb(delta)

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
	_update_line()

func _stop_drawing() -> void:
	is_drawing = false
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

	# Create segment shape for the line
	var segment := SegmentShape2D.new()
	segment.a = start_point
	segment.b = end_point
	collision_shape.shape = segment

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
