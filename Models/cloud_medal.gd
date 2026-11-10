extends Area3D

const ROTATION_SPEED = 2.0 # Degrees per frame of rotation

var Manager : Node = null
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var collision: CollisionShape3D = $CollisionShape3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
		
		mesh.visible = false
		collision.set_deferred("disabled", true)
		
		if audio_player and audio_player.stream:
			audio_player.play()
			await audio_player.finished
		if body.name == "VaneBody3D" or body.is_in_group("player"):
			body.global_transform = body.spawn_transform
		queue_free()
