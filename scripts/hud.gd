extends CanvasLayer

signal score_changed(new_score: int, old_score: int)
signal game_over

@onready var score_container: Node2D = $ScoreContainer
@onready var gravity_indicator: Node2D = $GravityIndicator

const SCORE_SIZE := 28.0
const SCORE_COLOR := Color.GREEN
const ZERO_SCORE_TIMEOUT := 5.0

var score: int = 0
var score_display: Node2D = null
var time_at_zero: float = 0.0
var gravity_arrow: Node2D = null

func _ready() -> void:
	_update_score_display()
	_setup_gravity_indicator()

func _process(delta: float) -> void:
	if score <= 0:
		time_at_zero += delta
		if time_at_zero >= ZERO_SCORE_TIMEOUT:
			game_over.emit()
	else:
		time_at_zero = 0.0

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

func get_score() -> int:
	return score

func reset() -> void:
	score = 0
	time_at_zero = 0.0
	_update_score_display()

func set_gravity_direction(direction: int) -> void:
	# direction: 0=North(down), 1=East(left), 2=South(up), 3=West(right)
	if gravity_arrow:
		gravity_arrow.rotation = direction * PI / 2

func _update_score_display() -> void:
	if score_display:
		score_display.queue_free()

	score_display = VectorFont.create_text(str(score), SCORE_SIZE, SCORE_COLOR, 2.5)
	score_container.add_child(score_display)

func _setup_gravity_indicator() -> void:
	gravity_arrow = Node2D.new()

	# Draw arrow pointing down (default gravity direction)
	var arrow := Line2D.new()
	arrow.width = 2.0
	arrow.default_color = Color.GREEN
	arrow.antialiased = true

	# Arrow stem
	arrow.add_point(Vector2(0, -10))
	arrow.add_point(Vector2(0, 10))
	gravity_arrow.add_child(arrow)

	# Arrow head left
	var head_left := Line2D.new()
	head_left.width = 2.0
	head_left.default_color = Color.GREEN
	head_left.antialiased = true
	head_left.add_point(Vector2(-6, 4))
	head_left.add_point(Vector2(0, 10))
	gravity_arrow.add_child(head_left)

	# Arrow head right
	var head_right := Line2D.new()
	head_right.width = 2.0
	head_right.default_color = Color.GREEN
	head_right.antialiased = true
	head_right.add_point(Vector2(6, 4))
	head_right.add_point(Vector2(0, 10))
	gravity_arrow.add_child(head_right)

	gravity_indicator.add_child(gravity_arrow)
