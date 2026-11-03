extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 12
const ROTATION_SPEED = 12 

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var visual_model : Node3D = $Vane
@onready var anim_player : AnimationPlayer = $Vane/AnimationPlayer

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		var model_offset := PI/2.0
		
		
		#Rotation logic
		if visual_model:
			var target_angle := atan2(direction.x,direction.z) - model_offset
			visual_model.rotation.y = lerp_angle(visual_model.rotation.y,target_angle,ROTATION_SPEED * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
