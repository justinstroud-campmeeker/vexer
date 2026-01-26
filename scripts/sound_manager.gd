extends Node

# Sound effects
var sfx_bounce: AudioStreamPlayer
var sfx_extra_life: AudioStreamPlayer
var sfx_game_over: AudioStreamPlayer
var sfx_lost_ball: AudioStreamPlayer
var sfx_new_game: AudioStreamPlayer

# Music
var music_menu: AudioStreamPlayer

func _ready() -> void:
	_setup_sounds()

func _setup_sounds() -> void:
	# Sound effects
	sfx_bounce = _create_player("res://resources/sound/bounce.wav")
	sfx_extra_life = _create_player("res://resources/sound/extra_life.wav")
	sfx_game_over = _create_player("res://resources/sound/game_over.wav")
	sfx_lost_ball = _create_player("res://resources/sound/lost_ball.wav")
	sfx_new_game = _create_player("res://resources/sound/new_game.wav")

	# Music (looping)
	music_menu = _create_player("res://resources/sound/menu_music.wav", true)

func _create_player(path: String, loop: bool = false) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	var stream := load(path) as AudioStream
	if stream:
		player.stream = stream
		if loop and stream is AudioStreamWAV:
			(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	add_child(player)
	return player

func play_bounce() -> void:
	sfx_bounce.play()

func play_extra_life() -> void:
	sfx_extra_life.play()

func play_game_over() -> void:
	sfx_game_over.play()

func play_lost_ball() -> void:
	sfx_lost_ball.play()

func play_new_game() -> void:
	sfx_new_game.play()

func start_menu_music() -> void:
	if not music_menu.playing:
		music_menu.play()

func stop_menu_music() -> void:
	music_menu.stop()
