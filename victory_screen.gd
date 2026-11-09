extends Node3D # (or CanvasLayer, depending on your root node type)
static var stored_final_time: float = 0.

@onready var world_environment: WorldEnvironment = $WorldEnvironment

@onready var title_label: Label = $VictoryUI/VBoxContainer/TitleLabel
@onready var time_label: Label = $VictoryUI/VBoxContainer/FinalTimeLabel
@onready var press_return_label: Label = $VictoryUI/VBoxContainer/PressReturnLabel


@onready var vane_model: Node3D = $Pivot
@onready var victory_audio: AudioStreamPlayer3D = $VictoryAudio
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
	if victory_audio and victory_audio.stream:
		victory_audio.play()
	
	# Set title text
	if title_label:
		title_label.text = "SEASONS CONQUERED!"
	
	if press_return_label:
		press_return_label.text = "Press Space to play again!"
	
	# Display final time from GlobalTime
	display_victory_stats(stored_final_time)

func _process(delta: float) -> void:
	if vane_model:
		vane_model.rotate_y(ROTATION_SPEED * delta)
	
	
	timer += delta
	if timer >= CYCLE_INTERVAL:
		timer = 0.0
		current_env_index = (current_env_index + 1) % environments.size()
		update_background()
		
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER or event.is_action_pressed("ui_accept"):
			get_tree().paused = false
			get_tree().change_scene_to_file("res://tscn folders/world.tscn")

func update_background() -> void:
	if world_environment:
		world_environment.environment = environments[current_env_index]



func display_victory_stats(elapsed_time: float) -> void:
	var minutes = int(elapsed_time / 60)
	var seconds = int(fmod(elapsed_time, 60))
	var msec = int(fmod(elapsed_time, 1) * 100)
	
	if time_label:
		time_label.text = "Final Time: %02d:%02d.%02d" % [minutes, seconds, msec]
