extends Area3D

@export var required_blocks: int = 2
@export var door : GridMap

var solved_count: int = 0
signal door_unlocked

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	door_unlocked.connect(_on_door_unlocked)

func _on_body_entered(body: Node3D) -> void:
	# Check if a moving pushable block entered the trigger zone
	if body is RigidBody3D and "UnlockBlock" in body.name:
		if body.visible:
			
			# Hide and remove the moving block pushed by the player
			body.hide()
			body.queue_free()
			
			solved_count += 1
			print("Block placed! Total solved: ", solved_count)
			
			# Check if both blocks have been successfully submitted
			if solved_count >= required_blocks:
				emit_signal("door_unlocked")
				print("Both blocks placed on spirals! Cave door unlocked.")

func _on_door_unlocked() -> void:
	if door:
		print("Removing door GridMap.")
		door.visible = false
		door.collision_layer = 0
		door.collision_mask = 0
