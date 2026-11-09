extends RigidBody3D

@export var push_force : float = 10.0
var spawn_transform : Transform3D
# Call this when the player hits the block

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_transform = global_transform

func respawn() -> void:
	# Reset physics state so momentum doesn't carry over
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	global_transform = spawn_transform
	
	# Make sure it's visible and active again
	visible = true
	freeze = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and body.has_method("is_dashing") and body.is_dashing():
		freeze = false
		
		# Calculate push direction
		var push_dir = (global_transform.origin - body.global_transform.origin).normalized()
		push_dir.y = 0.2 # Give it a slight upward bump
		
		# Apply force
		apply_central_impulse(push_dir * push_force)
