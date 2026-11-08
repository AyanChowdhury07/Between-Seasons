extends Area3D

const ROTATION_SPEED = 2 #Degrees per frame of rotation

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	var camera = get_viewport().get_camera_3d()
	if camera:
		# Get the camera's position
		var target_pos = camera.global_position
		
		# Lock the Y coordinate so the medal stays upright and doesn't tilt toward the sky/ground
		target_pos.y = global_position.y
		
		# Make the medal face the camera
		look_at(target_pos, Vector3.UP)
		
		# Optional: If the medal's flat face is pointing away from the camera, 
		# uncomment the line below to flip it around:
		# rotate_object_local(Vector3.UP, PI)

func _on_body_entered(body: Node3D) -> void:
	queue_free()
