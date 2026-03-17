extends Node2D
var rot_per_sec = 5

func _ready():
	%AnimationPlayer.play("idle")
	
func _process(delta):
	global_rotation += rot_per_sec * delta

func _on_area_2d_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
