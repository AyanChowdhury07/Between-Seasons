extends Node

enum Weather {SPRING, WINTER, SUMMER, AUTUMN}

@export var World_Environment : WorldEnvironment
@export var SpringGridMap : GridMap
@export var WinterGridMap : GridMap
@export var SummerGridMap : GridMap
@export var AutumnGridMap : GridMap

@export var block : Node3D

@export var WeatherUI : Sprite2D
@export var Player : CharacterBody3D

var cloud_medals_collected : int = 0

var gridmaps = {}
#Initialise background environments
var environments = {
	Weather.SPRING: preload("res://tres/Spring_env.tres"),
	Weather.WINTER: preload("res://tres/Winter_env.tres"),
	Weather.SUMMER: preload("res://tres/Summer_env.tres"),
	Weather.AUTUMN: preload("res://tres/Autumn_env.tres")
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gridmaps = {
		Weather.SPRING: SpringGridMap,
		Weather.WINTER: WinterGridMap,
		Weather.SUMMER: SummerGridMap,
		Weather.AUTUMN: AutumnGridMap
	}
	
	set_weather(Weather.SPRING) #starting weather

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
	
	if WeatherUI:
		WeatherUI.change_ui_weather(NewWeather)
	
	# Inside your weather change logic
	if NewWeather == Weather.SUMMER:
		for child in block.get_children():
			child.freeze = false
	else:
		for child in block.get_children():
			child.freeze = true
			child.linear_velocity = Vector3.ZERO
			
	
	#Change gridmaps
	update_gridmaps(NewWeather)
	
	#Change power ups
	update_PowerUps(NewWeather)
	
func update_gridmaps(NewWeather : Weather) -> void:
	for weather_type in gridmaps:
		var map = gridmaps[weather_type]
		if map:
			var is_active = (weather_type == NewWeather)
			map.visible = is_active
			map.collision_layer = 1 if is_active else 0
			map.collision_mask = 1 if is_active else 0

func update_PowerUps(NewWeather : Weather)-> void:
	if Player and Player.has_method("set_weather_state"):
		Player.set_weather_state(NewWeather)

func increment_cloud_medal() -> void:
	cloud_medals_collected += 1
