extends Node

enum Difficulty { EASY, MEDIUM, HARD }

var difficulty: Difficulty = Difficulty.MEDIUM

const SAVE_PATH := "user://high_scores.cfg"

var high_scores := {
	Difficulty.EASY: { "score": 0, "date": "" },
	Difficulty.MEDIUM: { "score": 0, "date": "" },
	Difficulty.HARD: { "score": 0, "date": "" },
}

func _ready() -> void:
	load_high_scores()

func get_difficulty_name(diff: Difficulty) -> String:
	match diff:
		Difficulty.EASY: return "EASY"
		Difficulty.MEDIUM: return "MEDIUM"
		Difficulty.HARD: return "HARD"
	return "UNKNOWN"

func get_gravity_mode() -> int:
	# Returns: 0 = no changes, 1 = up/down only, 2 = full rotation
	match difficulty:
		Difficulty.EASY: return 0
		Difficulty.MEDIUM: return 1
		Difficulty.HARD: return 2
	return 2

func get_spawn_multiplier() -> float:
	# Lower = slower spawns (easier)
	match difficulty:
		Difficulty.EASY: return 0.7
		Difficulty.MEDIUM: return 1.0
		Difficulty.HARD: return 1.2
	return 1.0

func check_high_score(score: int) -> bool:
	if score > high_scores[difficulty]["score"]:
		high_scores[difficulty]["score"] = score
		high_scores[difficulty]["date"] = _get_date_string()
		save_high_scores()
		return true
	return false

func get_high_score(diff: Difficulty) -> Dictionary:
	return high_scores[diff]

func _get_date_string() -> String:
	var datetime := Time.get_datetime_dict_from_system()
	return "%02d-%02d-%04d" % [datetime["month"], datetime["day"], datetime["year"]]

func save_high_scores() -> void:
	var config := ConfigFile.new()

	for diff in high_scores.keys():
		var section := get_difficulty_name(diff)
		config.set_value(section, "score", high_scores[diff]["score"])
		config.set_value(section, "date", high_scores[diff]["date"])

	config.save(SAVE_PATH)

func load_high_scores() -> void:
	var config := ConfigFile.new()
	var err := config.load(SAVE_PATH)

	if err != OK:
		return  # No save file yet

	for diff in high_scores.keys():
		var section := get_difficulty_name(diff)
		if config.has_section(section):
			high_scores[diff]["score"] = config.get_value(section, "score", 0)
			high_scores[diff]["date"] = config.get_value(section, "date", "")
