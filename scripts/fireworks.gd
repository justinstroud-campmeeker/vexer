extends Node2D

const SPAWN_INTERVAL_MIN := 0.3
const SPAWN_INTERVAL_MAX := 1.0
const PARTICLE_COUNT := 20
const PARTICLE_SPEED := 200.0
const PARTICLE_LIFETIME := 1.5
const TRAIL_LENGTH := 5

var viewport_size: Vector2
var spawn_timer: float = 0.0
var next_spawn_time: float = 0.5

class FireworkParticle:
	var position: Vector2
	var velocity: Vector2
	var color: Color
	var lifetime: float
	var max_lifetime: float
	var trail: Array[Vector2]

var particles: Array[FireworkParticle] = []
var particle_lines: Array[Line2D] = []

func _ready() -> void:
	viewport_size = get_viewport_rect().size
	# Pre-create line nodes for particles
	for i in range(100):
		var line := Line2D.new()
		line.width = 3.0
		line.antialiased = true
		line.visible = false
		add_child(line)
		particle_lines.append(line)

func set_viewport_size(new_size: Vector2) -> void:
	viewport_size = new_size

func _process(delta: float) -> void:
	spawn_timer += delta

	if spawn_timer >= next_spawn_time:
		spawn_timer = 0.0
		next_spawn_time = randf_range(SPAWN_INTERVAL_MIN, SPAWN_INTERVAL_MAX)
		_spawn_firework()

	_update_particles(delta)
	_draw_particles()

func _spawn_firework() -> void:
	var burst_pos := Vector2(
		randf_range(100, viewport_size.x - 100),
		randf_range(100, viewport_size.y - 200)
	)

	var base_color := Color.from_hsv(randf(), 0.8, 1.0)

	for i in range(PARTICLE_COUNT):
		var p := FireworkParticle.new()
		p.position = burst_pos
		var angle := (float(i) / PARTICLE_COUNT) * TAU + randf_range(-0.2, 0.2)
		var speed := PARTICLE_SPEED * randf_range(0.5, 1.0)
		p.velocity = Vector2(cos(angle), sin(angle)) * speed
		p.color = base_color.lerp(Color.WHITE, randf_range(0, 0.3))
		p.lifetime = PARTICLE_LIFETIME
		p.max_lifetime = PARTICLE_LIFETIME
		p.trail = [burst_pos]
		particles.append(p)

func _update_particles(delta: float) -> void:
	var to_remove: Array[int] = []

	for i in range(particles.size()):
		var p := particles[i]
		p.lifetime -= delta
		p.velocity.y += 100 * delta  # Gravity
		p.velocity *= 0.98  # Drag
		p.position += p.velocity * delta

		# Update trail
		p.trail.insert(0, p.position)
		if p.trail.size() > TRAIL_LENGTH:
			p.trail.resize(TRAIL_LENGTH)

		if p.lifetime <= 0:
			to_remove.append(i)

	# Remove dead particles (reverse order)
	for i in range(to_remove.size() - 1, -1, -1):
		particles.remove_at(to_remove[i])

func _draw_particles() -> void:
	# Hide all lines first
	for line in particle_lines:
		line.visible = false

	# Draw active particles
	for i in range(mini(particles.size(), particle_lines.size())):
		var p := particles[i]
		var line := particle_lines[i]
		line.visible = true
		line.clear_points()

		var alpha := p.lifetime / p.max_lifetime
		line.default_color = Color(p.color.r, p.color.g, p.color.b, alpha)

		for point in p.trail:
			line.add_point(point)
