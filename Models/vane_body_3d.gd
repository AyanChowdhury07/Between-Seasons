extends CharacterBody3D

const SPEED = 10
const JUMP_VELOCITY = 16
const ROTATION_SPEED = 24

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


@onready var visual_model : Node3D = $ModelPivot
@onready var anim_player : AnimationPlayer = $ModelPivot/Vane/AnimationPlayer

@export var Mouse_Sensitivity : float = 0.003

@onready var CameraPivot : Node3D = $CameraController/CameraTarget/CameraPivot
@onready var CameraController: Node3D = $CameraController

var current_weather_state : int  = 0
#(0: Spring, 1: Winter, 2: Summer, 3: Autumn)
var has_used_air_ability : bool = false
#===================
#Spring variables
#===================
@onready var branch_visual : Node3D = $Branch_visual # Your wooden cuboid branch
@onready var ray_cast_right : RayCast3D = $RayCastRight
@onready var ray_cast_left : RayCast3D = $RayCastLeft

var is_spring_clinging : bool = false
@export var wall_jump_up_velocity : float = 12.0
@export var wall_jump_out_boost : float = 10.0

#===================
#Autumn variables
var is_floating : bool = false
var float_timer : float = 0.0
@export var max_float_duration : float = 2.5
#===================

#===================
#Summer variables
var is_dashing : bool = false
var dash_timer : float = 0.0
@export var dash_duration : float = 0.5
@export var dash_speed_boost : float = 50.0 #Dash speed
var dash_direction : Vector3 = Vector3.ZERO #initialise direction
#===================


func _physics_process(delta: float) -> void:

	# Add the gravity.
	if not is_on_floor():
		if is_spring_clinging:
			velocity.y = 0 # Zero gravity / no sliding down
			velocity.x = 0
			velocity.z = 0
		elif is_floating and velocity.y < 0:
			velocity.y -= (gravity * 0.1) * delta #Autumn float
		else:
			velocity.y -= gravity * delta
	else:
		end_spring_cling() #end spring action
		is_floating = false #end autumn action
		has_used_air_ability = false #reset ability once landed

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif is_spring_clinging:
			try_spring_wall_jump()
	
	if Input.is_action_just_released("ui_accept") and velocity.y > 0:
		velocity.y *= 0.5 
	
	#Weather actions cases
	if Input.is_action_just_pressed("Weather_Power_UP"):
		# If we are in the air and trying to use a non-Spring ability after already using one, block it completely
		if not is_on_floor() and current_weather_state != 0 and has_used_air_ability:
			pass # Do nothing (prevents spamming)
		else:
			match current_weather_state:
				0:
					try_spring_cling()
				1:
					try_winter_sneeze()
					has_used_air_ability = true
				2:
					try_summer_dash()
					has_used_air_ability = true
				3:
					try_autumn_float()
					has_used_air_ability = true
	 # Release spring cling when power-up button is let go
	if Input.is_action_just_released("Weather_Power_UP") and current_weather_state == 0:
		end_spring_cling()
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	#User input and camera rotation taken into account for Vector3 direction
	var direction := (CameraController.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	#Summer dash logic
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0: #finish duration
			is_dashing = false #stop dash
		else:
			velocity.x = dash_direction.x * dash_speed_boost
			velocity.z = dash_direction.z * dash_speed_boost
	
	
	elif not is_spring_clinging and direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		#Camera relative rotation logic
		if visual_model:
			var model_offset := PI / 2.0
			var target_angle := atan2(direction.x, direction.z) - model_offset
			visual_model.rotation.y = lerp_angle(visual_model.rotation.y, target_angle, ROTATION_SPEED * delta)
	elif not is_spring_clinging:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	_update_animations()
	
	if is_dashing:
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			
			# Check if it's one of your pushable blocks
			if collider is RigidBody3D and not collider.freeze:
				# Calculate push direction away from the surface hit
				var push_dir = -collision.get_normal()
				push_dir.y = 0.2 # Slight upward bias to help it tip over
				
				# Apply the physical impulse to knock it over
				collider.apply_central_impulse(push_dir * 15.0)

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
	velocity.y = JUMP_VELOCITY * 2 #Rocket jump up
		
	if visual_model:
		var forward_dir = -visual_model.global_transform.basis.z
		velocity += forward_dir * 6.0

func try_summer_dash():
	is_dashing = true
	dash_timer = dash_duration #Restart timer to begin
	is_floating = false #Cancel any current autumn float to avoid overlapping abilities
	
	if visual_model:
		dash_direction = visual_model.global_transform.basis.x #Based on where facing
	else:
		dash_direction = Vector3.FORWARD #Based on camera when stationary
		
	velocity.y = 10.0
	velocity.x = dash_direction.x * (dash_speed_boost * 1.2)
	velocity.z = dash_direction.z * (dash_speed_boost * 1.2)
	

func try_spring_cling():
	# Only cling if in air and touching a wall on either side
	if not is_on_floor() and current_weather_state == 0:
		if ray_cast_right.is_colliding() or ray_cast_left.is_colliding():
			is_floating = false
			is_dashing = false
			is_spring_clinging = true
			
			if branch_visual:
				branch_visual.visible = true

func try_spring_wall_jump():
	var push_direction = Vector3.ZERO
	
	if ray_cast_right.is_colliding():
		var wall_normal = ray_cast_right.get_collision_normal()
		push_direction = wall_normal
	elif ray_cast_left.is_colliding():
		var wall_normal = ray_cast_left.get_collision_normal()
		push_direction = wall_normal
		
	velocity.y = wall_jump_up_velocity
	velocity.x = push_direction.x * wall_jump_out_boost
	velocity.z = push_direction.z * wall_jump_out_boost
	
	end_spring_cling()

func end_spring_cling():
	is_spring_clinging = false
	if branch_visual:
		branch_visual.visible = false

func update_branch_visual():
	if not branch_visual:
		return
		
	var target_point = Vector3.ZERO
	var colliding_ray = null
	
	if ray_cast_right.is_colliding():
		colliding_ray = ray_cast_right
		target_point = ray_cast_right.get_collision_point()
	elif ray_cast_left.is_colliding():
		colliding_ray = ray_cast_left
		target_point = ray_cast_left.get_collision_point()
		
	if colliding_ray:
		var start_point = global_position + Vector3(0, 0.5, 0)

		branch_visual.visible = true
		# Position branch at the midpoint between player and wall collision point
		branch_visual.global_position = start_point + ((target_point - start_point) * 0.5)
	else:
		branch_visual.visible = false

func try_autumn_float() -> void:
	velocity.y = 8.0
	is_floating = true
	

func set_weather_state(new_weather : int) -> void:
	current_weather_state = new_weather
	is_floating = false #Stops floating while other weathers
	is_spring_clinging = false #Stop cling in other weathers
	has_used_air_ability = false #Allows abilities to mash up when switching eg float after sneeze

func _process(delta: float) -> void:
	if is_spring_clinging:
		update_branch_visual()
	
	# Smoothly match the camera controller's position to the player's position every frame
	if CameraController:
		CameraController.global_position = CameraController.global_position.lerp(global_position, 15.0 * delta)


func _on_death_zone_body_entered(body: Node3D) -> void:
	if body == self:
		get_tree().change_scene_to_file("res://tscn folders/world.tscn")
