extends Node2D

@export var type: String
@export var negative = false
@export var total = 6
@export var direction: Vector2
@export var can_dequeue = false

var done = false
var rot_per_sec = 2

func setup(path: String):
	for i in range(total):
		var new = Sprite2D.new()
		new.texture = load(path)
		new.rotation = deg_to_rad(360) * i / total
		%spokes.add_child(new)

func _process(delta: float) -> void:
	if !global.game_over:
		global_position += direction * global.BASE_SPEED
		global_rotation += rot_per_sec * delta
		if negative and !done:
			rot_per_sec *= -1 
			done = true


func _on_timer_timeout() -> void:
	can_dequeue = true


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		$AnimationPlayerHit.play("contact")
