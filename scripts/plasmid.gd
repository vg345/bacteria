extends Node2D

@export var type: String
@export var negative = false
@export var can_dequeue = false

var done = false

var rot_per_sec = 5

func _ready():
	%AnimationPlayer.play("idle")
	
func _process(delta):
	global_rotation += rot_per_sec * delta
	if negative and !done:
		rot_per_sec *= -1 
		done = true

func _on_area_2d_area_entered(area: Area2D) -> void:
	if can_dequeue:
		queue_free()
