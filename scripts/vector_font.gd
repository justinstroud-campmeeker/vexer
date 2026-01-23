extends Node
class_name VectorFont

# Tempest-style vector font definitions
# Each character is defined as an array of line segments
# Each segment is [x1, y1, x2, y2] normalized to a 0-1 grid

const CHAR_WIDTH := 0.7
const CHAR_HEIGHT := 1.0
const CHAR_SPACING := 0.2

# Number definitions (Tempest-style angular vectors)
const CHARACTERS := {
	"0": [
		[0, 0, 1, 0],      # top
		[1, 0, 1, 1],      # right
		[1, 1, 0, 1],      # bottom
		[0, 1, 0, 0],      # left
		[0, 1, 1, 0],      # diagonal
	],
	"1": [
		[0.5, 0, 0.5, 1],  # vertical
		[0.2, 0.2, 0.5, 0], # top serif
		[0.2, 1, 0.8, 1],  # bottom
	],
	"2": [
		[0, 0, 1, 0],      # top
		[1, 0, 1, 0.5],    # right top
		[1, 0.5, 0, 0.5],  # middle
		[0, 0.5, 0, 1],    # left bottom
		[0, 1, 1, 1],      # bottom
	],
	"3": [
		[0, 0, 1, 0],      # top
		[1, 0, 1, 1],      # right
		[1, 1, 0, 1],      # bottom
		[0.3, 0.5, 1, 0.5], # middle
	],
	"4": [
		[0, 0, 0, 0.5],    # left top
		[0, 0.5, 1, 0.5],  # middle
		[1, 0, 1, 1],      # right full
	],
	"5": [
		[1, 0, 0, 0],      # top
		[0, 0, 0, 0.5],    # left top
		[0, 0.5, 1, 0.5],  # middle
		[1, 0.5, 1, 1],    # right bottom
		[1, 1, 0, 1],      # bottom
	],
	"6": [
		[1, 0, 0, 0],      # top
		[0, 0, 0, 1],      # left
		[0, 1, 1, 1],      # bottom
		[1, 1, 1, 0.5],    # right bottom
		[1, 0.5, 0, 0.5],  # middle
	],
	"7": [
		[0, 0, 1, 0],      # top
		[1, 0, 0.3, 1],    # diagonal
	],
	"8": [
		[0, 0, 1, 0],      # top
		[1, 0, 1, 1],      # right
		[1, 1, 0, 1],      # bottom
		[0, 1, 0, 0],      # left
		[0, 0.5, 1, 0.5],  # middle
	],
	"9": [
		[0, 0.5, 1, 0.5],  # middle
		[0, 0.5, 0, 0],    # left top
		[0, 0, 1, 0],      # top
		[1, 0, 1, 1],      # right
		[1, 1, 0, 1],      # bottom
	],
	"A": [
		[0, 1, 0.5, 0],    # left diagonal
		[0.5, 0, 1, 1],    # right diagonal
		[0.15, 0.6, 0.85, 0.6], # middle bar
	],
	"B": [
		[0, 0, 0, 1],      # left
		[0, 0, 0.8, 0],    # top
		[0.8, 0, 1, 0.15], # top right corner
		[1, 0.15, 1, 0.35], # right top
		[1, 0.35, 0.8, 0.5], # middle right corner
		[0.8, 0.5, 0, 0.5], # middle
		[0.8, 0.5, 1, 0.65], # lower middle corner
		[1, 0.65, 1, 0.85], # right bottom
		[1, 0.85, 0.8, 1], # bottom right corner
		[0.8, 1, 0, 1],    # bottom
	],
	"C": [
		[1, 0, 0, 0],      # top
		[0, 0, 0, 1],      # left
		[0, 1, 1, 1],      # bottom
	],
	"D": [
		[0, 0, 0, 1],      # left
		[0, 0, 0.7, 0],    # top
		[0.7, 0, 1, 0.3],  # top right
		[1, 0.3, 1, 0.7],  # right
		[1, 0.7, 0.7, 1],  # bottom right
		[0.7, 1, 0, 1],    # bottom
	],
	"E": [
		[1, 0, 0, 0],      # top
		[0, 0, 0, 1],      # left
		[0, 1, 1, 1],      # bottom
		[0, 0.5, 0.7, 0.5], # middle
	],
	"F": [
		[1, 0, 0, 0],      # top
		[0, 0, 0, 1],      # left
		[0, 0.5, 0.7, 0.5], # middle
	],
	"G": [
		[1, 0, 0, 0],      # top
		[0, 0, 0, 1],      # left
		[0, 1, 1, 1],      # bottom
		[1, 1, 1, 0.5],    # right bottom
		[1, 0.5, 0.5, 0.5], # middle
	],
	"H": [
		[0, 0, 0, 1],      # left
		[1, 0, 1, 1],      # right
		[0, 0.5, 1, 0.5],  # middle
	],
	"I": [
		[0.2, 0, 0.8, 0],  # top
		[0.5, 0, 0.5, 1],  # middle
		[0.2, 1, 0.8, 1],  # bottom
	],
	"J": [
		[0.2, 0, 1, 0],    # top
		[0.7, 0, 0.7, 0.85], # right
		[0.7, 0.85, 0.5, 1], # curve
		[0.5, 1, 0.2, 0.85], # curve
		[0.2, 0.85, 0.2, 0.6], # left bottom
	],
	"K": [
		[0, 0, 0, 1],      # left
		[1, 0, 0, 0.5],    # top diagonal
		[0, 0.5, 1, 1],    # bottom diagonal
	],
	"L": [
		[0, 0, 0, 1],      # left
		[0, 1, 1, 1],      # bottom
	],
	"M": [
		[0, 1, 0, 0],      # left
		[0, 0, 0.5, 0.4],  # left diagonal
		[0.5, 0.4, 1, 0],  # right diagonal
		[1, 0, 1, 1],      # right
	],
	"N": [
		[0, 1, 0, 0],      # left
		[0, 0, 1, 1],      # diagonal
		[1, 1, 1, 0],      # right
	],
	"O": [
		[0, 0, 1, 0],      # top
		[1, 0, 1, 1],      # right
		[1, 1, 0, 1],      # bottom
		[0, 1, 0, 0],      # left
	],
	"P": [
		[0, 0, 0, 1],      # left
		[0, 0, 1, 0],      # top
		[1, 0, 1, 0.5],    # right
		[1, 0.5, 0, 0.5],  # middle
	],
	"Q": [
		[0, 0, 1, 0],      # top
		[1, 0, 1, 0.8],    # right
		[1, 0.8, 0.6, 1],  # bottom right
		[0.6, 1, 0, 1],    # bottom
		[0, 1, 0, 0],      # left
		[0.6, 0.7, 1, 1],  # tail
	],
	"R": [
		[0, 0, 0, 1],      # left
		[0, 0, 1, 0],      # top
		[1, 0, 1, 0.5],    # right
		[1, 0.5, 0, 0.5],  # middle
		[0.5, 0.5, 1, 1],  # diagonal
	],
	"S": [
		[1, 0, 0, 0],      # top
		[0, 0, 0, 0.5],    # left top
		[0, 0.5, 1, 0.5],  # middle
		[1, 0.5, 1, 1],    # right bottom
		[1, 1, 0, 1],      # bottom
	],
	"T": [
		[0, 0, 1, 0],      # top
		[0.5, 0, 0.5, 1],  # middle
	],
	"U": [
		[0, 0, 0, 1],      # left
		[0, 1, 1, 1],      # bottom
		[1, 1, 1, 0],      # right
	],
	"V": [
		[0, 0, 0.5, 1],    # left diagonal
		[0.5, 1, 1, 0],    # right diagonal
	],
	"W": [
		[0, 0, 0.25, 1],   # left
		[0.25, 1, 0.5, 0.5], # left middle
		[0.5, 0.5, 0.75, 1], # right middle
		[0.75, 1, 1, 0],   # right
	],
	"X": [
		[0, 0, 1, 1],      # diagonal 1
		[1, 0, 0, 1],      # diagonal 2
	],
	"Y": [
		[0, 0, 0.5, 0.5],  # left diagonal
		[1, 0, 0.5, 0.5],  # right diagonal
		[0.5, 0.5, 0.5, 1], # stem
	],
	"Z": [
		[0, 0, 1, 0],      # top
		[1, 0, 0, 1],      # diagonal
		[0, 1, 1, 1],      # bottom
	],
	"+": [
		[0.5, 0.2, 0.5, 0.8], # vertical
		[0.2, 0.5, 0.8, 0.5], # horizontal
	],
	"-": [
		[0.2, 0.5, 0.8, 0.5], # horizontal
	],
	" ": [],
	":": [
		[0.4, 0.25, 0.6, 0.25], # top dot
		[0.6, 0.25, 0.6, 0.35],
		[0.6, 0.35, 0.4, 0.35],
		[0.4, 0.35, 0.4, 0.25],
		[0.4, 0.65, 0.6, 0.65], # bottom dot
		[0.6, 0.65, 0.6, 0.75],
		[0.6, 0.75, 0.4, 0.75],
		[0.4, 0.75, 0.4, 0.65],
	],
	".": [
		[0.4, 0.8, 0.6, 0.8],
		[0.6, 0.8, 0.6, 1],
		[0.6, 1, 0.4, 1],
		[0.4, 1, 0.4, 0.8],
	],
	"!": [
		[0.5, 0, 0.5, 0.6], # stem
		[0.4, 0.8, 0.6, 0.8], # dot
		[0.6, 0.8, 0.6, 1],
		[0.6, 1, 0.4, 1],
		[0.4, 1, 0.4, 0.8],
	],
}

static func create_text(text: String, size: float, color: Color, line_width: float = 2.0) -> Node2D:
	var container := Node2D.new()
	var x_offset := 0.0

	for c in text.to_upper():
		if c in CHARACTERS:
			var char_node := _create_character(c, size, color, line_width)
			char_node.position.x = x_offset
			container.add_child(char_node)
		x_offset += size * (CHAR_WIDTH + CHAR_SPACING)

	return container

static func _create_character(c: String, size: float, color: Color, line_width: float) -> Node2D:
	var char_node := Node2D.new()
	var segments: Array = CHARACTERS.get(c, [])

	for segment in segments:
		var line := Line2D.new()
		line.width = line_width
		line.default_color = color
		line.antialiased = true

		var x1: float = segment[0] * size * CHAR_WIDTH
		var y1: float = segment[1] * size * CHAR_HEIGHT
		var x2: float = segment[2] * size * CHAR_WIDTH
		var y2: float = segment[3] * size * CHAR_HEIGHT

		line.add_point(Vector2(x1, y1))
		line.add_point(Vector2(x2, y2))

		char_node.add_child(line)

	return char_node

static func get_text_width(text: String, size: float) -> float:
	return text.length() * size * (CHAR_WIDTH + CHAR_SPACING) - size * CHAR_SPACING
