extends Node2D

@export var type: String
@export var negative = false
@export var total = 6
var direction= Vector2(1,0)

func setup(path: String):
	for i in range(total):
		var new = Sprite2D.new()
		new.texture = load(path)
		new.rotation = deg_to_rad(360) * i / total
		%spokes.add_child(new)

func _process(delta: float) -> void:
	global_position += direction * global.BASE_SPEED
	
