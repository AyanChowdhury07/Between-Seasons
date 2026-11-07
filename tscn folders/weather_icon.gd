extends Sprite2D

# Preload your 4 PNG sprite sheets
var ui_textures = {
	0: preload("res://pngs/UI/Spring UI.png"),  # Spring
	1: preload("res://pngs/UI/Winter ui.png"),  # Winter
	2: preload("res://pngs/UI/Summer UI.png"),  # Summer
	3: preload("res://pngs/UI/Autumn ui.png")   # Autumn
}

var time_accumulator : float = 0.0
@export var fps : float = 6.0

func change_ui_weather(weather_index: int) -> void:
	if ui_textures.has(weather_index):
		texture = ui_textures[weather_index]
		time_accumulator = 0.0  # Reset animation on weather change
		frame = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Automatically cycle through 4  frames (0 - 3)
	time_accumulator += delta * fps
	if hframes > 0:
		frame = int(time_accumulator) % hframes
	pass
