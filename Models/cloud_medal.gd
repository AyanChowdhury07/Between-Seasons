extends Area3D

const ROTATION_SPEED = 2.0 # Degrees per frame of rotation

var Manager : Node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Automatically hunt down the WorldManager in the current level scene tree
	Manager = get_tree().current_scene.get_node_or_null("WorldManager")
	if not Manager:
		print("Warning: Cloud Medal could not find WorldManager!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate_y(ROTATION_SPEED * delta)
		
func _on_body_entered(body: Node3D) -> void:
	if body.name == "VaneBody3D" or body.is_in_group("player"):
		if Manager and Manager.has_method("increment_cloud_medal"):
			Manager.increment_cloud_medal()
		
		queue_free()
