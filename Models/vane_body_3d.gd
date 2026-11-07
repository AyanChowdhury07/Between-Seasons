extends CharacterBody3D

const SPEED = 10
const JUMP_VELOCITY = 8
const ROTATION_SPEED = 24 

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var visual_model : Node3D = $Vane
@onready var anim_player : AnimationPlayer = $Vane/AnimationPlayer

@export var Mouse_Sensitivity : float = 0.003

@onready var CameraPivot : Node3D = $CameraController/CameraTarget/CameraPivot
@onready var CameraController: Node3D = $CameraController

var current_weather_state : int  = 0
#(0: Spring, 1: Winter, 2: Summer, 3: Autumn)

#For autumn power up
var is_floating : bool = false
var float_timer : float = 0.0
@export var max_float_duration : float = 2.5

func _physics_process(delta: float) -> void:

	# Add the gravity.
	if not is_on_floor():
		if is_floating and velocity.y < 0:
			velocity.y -= (gravity * 0.1) * delta
		else:
			velocity.y -= gravity * delta
	else:
		is_floating = false
		#Reset's when touching ground

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("Weather_Power_UP"):
		match current_weather_state:
			1:
				try_winter_sneeze()
			3:
				try_autumn_float()
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	#User input and camera rotation taken into account for Vector3 direction
	var direction := (CameraController.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	
	
	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		#Camera relative rotation logic
		if visual_model:
			var model_offset := PI / 2.0
			var target_angle := atan2(direction.x, direction.z) - model_offset
			visual_model.rotation.y = lerp_angle(visual_model.rotation.y, target_angle, ROTATION_SPEED * delta)
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	_update_animations()

func _update_animations() -> void:
	if not anim_player:
		return
		
	var horizontal_speed := Vector3(velocity.x, 0,velocity.z).length()

	if not is_on_floor():
		if anim_player.has_animation("WalkCycle"):
			anim_player.speed_scale = 10.0 # Play at 2x speed for jumping
			if anim_player.current_animation != "WalkCycle":
				anim_player.play("WalkCycle")
	elif horizontal_speed > 0.1: # Moving on the floor
		if anim_player.has_animation("WalkCycle"):
			# Play at normal speed when walking
			anim_player.speed_scale = 5.0
			if anim_player.current_animation != "WalkCycle":
				anim_player.play("WalkCycle")
	else:
		# Stop or pause the animation when standing completely still
		anim_player.stop()

func _input(event):
	
	
	if event is InputEventMouseMotion:
		#Rotate horizontally using Mouse X
		$CameraController.rotate_y(-event.relative.x * Mouse_Sensitivity)
		
		#Rotate the Pivot vertically  using Mouse Y
		if CameraPivot:
			CameraPivot.rotation.x -= event.relative.y * Mouse_Sensitivity
			
			# 3. Clamp the vertical rotation so the camera can't flip upside down
			# Limit between -70 degrees and +60 degrees
			CameraPivot.rotation.x = clamp(
				CameraPivot.rotation.x, deg_to_rad(-70), deg_to_rad(60))
			
				
				
				

func try_winter_sneeze() -> void:
	velocity.y = 18.0 #Rocket jump up
		
	if visual_model:
		var forward_dir = -visual_model.global_transform.basis.z
		velocity += forward_dir * 6.0

func try_autumn_float() -> void:
	velocity.y = 8.0
	is_floating = true
	

func set_weather_state(new_weather : int) -> void:
	current_weather_state = new_weather

func _process(delta: float) -> void:
	# Smoothly match the camera controller's position to the player's position every frame
	if CameraController:
		CameraController.global_position = CameraController.global_position.lerp(global_position, 15.0 * delta)
