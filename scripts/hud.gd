extends CanvasLayer

signal score_changed(new_score: int, old_score: int)
signal game_over

@onready var score_container: Node2D = $ScoreContainer
@onready var gravity_indicator: Node2D = $GravityIndicator

const SCORE_SIZE := 28.0
const SCORE_COLOR := Color.GREEN
const MAX_BALLS_LOST := 20

var score: int = 0
var balls_lost: int = 0
var score_display: Node2D = null
var gravity_arrow: Node2D = null
var balls_lost_container: CanvasLayer = null
var balls_lost_display: Node2D = null

func _ready() -> void:
	_update_score_display()
	_setup_gravity_indicator()
	_setup_balls_lost_display()
	_update_layout()
	get_tree().root.size_changed.connect(_on_viewport_resized)

func _on_viewport_resized() -> void:
	_update_layout()

func _update_layout() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	gravity_indicator.position = Vector2(viewport_size.x - 30, 30)
	_update_balls_lost_display()

func _setup_balls_lost_display() -> void:
	balls_lost_container = CanvasLayer.new()
	balls_lost_container.layer = 15
	add_child(balls_lost_container)
	_update_balls_lost_display()

func _update_balls_lost_display() -> void:
	if balls_lost_display:
		balls_lost_display.queue_free()

	var remaining := MAX_BALLS_LOST - balls_lost
	var lost_text := "LIVES: " + str(remaining)

	var color: Color
	if remaining > 10:
		color = Color.GREEN
	elif remaining > 5:
		color = Color.YELLOW
	else:
		color = Color.RED

	balls_lost_display = VectorFont.create_text(lost_text, 20.0, color, 3.0)
	var text_width := VectorFont.get_text_width(lost_text, 20.0)
	var viewport_size := get_viewport().get_visible_rect().size
	balls_lost_display.position = Vector2(viewport_size.x - text_width - 20, viewport_size.y - 40)
	balls_lost_container.add_child(balls_lost_display)

func add_score(points: int) -> void:
	var old_score := score
	score += points
	score = maxi(score, 0)
	_update_score_display()
	score_changed.emit(score, old_score)

func subtract_score(points: int) -> void:
	var old_score := score
	score -= points
	score = maxi(score, 0)
	_update_score_display()
	score_changed.emit(score, old_score)

func add_ball_lost() -> void:
	balls_lost += 1
	_update_balls_lost_display()
	if balls_lost >= MAX_BALLS_LOST:
		game_over.emit()

func get_score() -> int:
	return score

func reset() -> void:
	score = 0
	balls_lost = 0
	_update_score_display()
	_update_balls_lost_display()

func set_gravity_direction(direction: int) -> void:
	# direction: 0=North(down), 1=East(left), 2=South(up), 3=West(right)
	if gravity_arrow:
		gravity_arrow.rotation = direction * PI / 2

func _update_score_display() -> void:
	if score_display:
		score_display.queue_free()

	score_display = VectorFont.create_text(str(score), SCORE_SIZE, SCORE_COLOR, 3.5)
	score_container.add_child(score_display)

func _setup_gravity_indicator() -> void:
	gravity_arrow = Node2D.new()

	# Draw arrow pointing down (default gravity direction)
	var arrow := Line2D.new()
	arrow.width = 3.0
	arrow.default_color = Color.GREEN
	arrow.antialiased = true

	# Arrow stem
	arrow.add_point(Vector2(0, -10))
	arrow.add_point(Vector2(0, 10))
	gravity_arrow.add_child(arrow)

	# Arrow head left
	var head_left := Line2D.new()
	head_left.width = 3.0
	head_left.default_color = Color.GREEN
	head_left.antialiased = true
	head_left.add_point(Vector2(-6, 4))
	head_left.add_point(Vector2(0, 10))
	gravity_arrow.add_child(head_left)

	# Arrow head right
	var head_right := Line2D.new()
	head_right.width = 3.0
	head_right.default_color = Color.GREEN
	head_right.antialiased = true
	head_right.add_point(Vector2(6, 4))
	head_right.add_point(Vector2(0, 10))
	gravity_arrow.add_child(head_right)

	gravity_indicator.add_child(gravity_arrow)
