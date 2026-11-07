extends Node

enum Weather {SPRING, WINTER, SUMMER, AUTUMN}

@export var World_Environment : WorldEnvironment
@export var SummerGridMap : GridMap

#Initialise background environments

var environments = {
	Weather.SPRING: preload("res://tres/Spring_env.tres"),
	Weather.WINTER: preload("res://tres/Winter_env.tres"),
	Weather.SUMMER: preload("res://tres/Summer_env.tres"),
	Weather.AUTUMN: preload("res://tres/Autumn_env.tres")
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_weather(Weather.SUMMER)
	
	pass # Replace with function body.

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.physical_keycode == KEY_1:
			set_weather(Weather.SPRING)
		elif event.physical_keycode == KEY_2:
			set_weather(Weather.WINTER)
		elif event.physical_keycode == KEY_3:
			set_weather(Weather.SUMMER)
		elif event.physical_keycode == KEY_4:
			set_weather(Weather.AUTUMN)
 
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func set_weather(NewWeather : Weather) -> void:
	
	#Change background
	if World_Environment and environments.has(NewWeather):
		World_Environment.environment = environments[NewWeather]
	
	#Change gridmaps
	update_gridmaps()
	
	#Change power ups
	update_PowerUps()
	
func update_gridmaps() -> void:
	pass
	#update later

func update_PowerUps()-> void:
	pass
	#update later
