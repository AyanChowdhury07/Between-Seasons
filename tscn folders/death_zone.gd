extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Automatically listen for anything entering the death zone
	body_entered.connect(_on_death_zone_body_entered)

func _on_death_zone_body_entered(body: Node3D) -> void:
	# Check if the object that fell in is an unlock block
	if body is RigidBody3D and "UnlockBlock" in body.name:
		# Check if the block has our respawn function and call it!
		if body.has_method("respawn"):
			body.respawn()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
