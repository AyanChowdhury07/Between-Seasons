extends Node3D # (or CanvasLayer, depending on your root node type)

@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var time_label: Label = $UI/VBoxContainer/FinalTimeLabel # Adjust path to match your label node
@onready var vane_model : Node3D = $Pivot
#4 seasonal environments
var environments = [
	preload("res://tres/Spring_env.tres"),
	preload("res://tres/Winter_env.tres"),
	preload("res://tres/Summer_env.tres"),
	preload("res://tres/Autumn_env.tres")
]

var current_env_index: int = 0
var timer: float = 0.0
const CYCLE_INTERVAL: float = 2.0 #2 seconds
const ROTATION_SPEED: float = 2.0

func _ready() -> void:
	update_background()

func _process(delta: float) -> void:
	if vane_model:
		vane_model.rotate_y(ROTATION_SPEED * delta)
	
	
	timer += delta
	if timer >= CYCLE_INTERVAL:
		timer = 0.0
		current_env_index = (current_env_index + 1) % environments.size()
		update_background()

func update_background() -> void:
	if world_environment:
		world_environment.environment = environments[current_env_index]


func display_victory_stats(elapsed_time: float) -> void:
	var minutes = int(elapsed_time / 60)
	var seconds = int(fmod(elapsed_time, 60))
	var msec = int(fmod(elapsed_time, 1) * 100)
	
	if time_label:
		time_label.text = "Final Time: %02d:%02d.%02d" % [minutes, seconds, msec]
