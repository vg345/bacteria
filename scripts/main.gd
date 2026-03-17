extends Node2D

var dist = 20
@onready var left_limit = %mark1.global_position.x + 50
@onready var right_limit = %mark2.global_position.x - 50
@onready var up_limit = %mark1.global_position.y + 50
@onready var down_limit = %mark2.global_position.y - 50



func _process(_delta):
	if Input.is_action_pressed("down"):
		%player.global_position.y = min(%player.global_position.y + dist, down_limit)
	
	if Input.is_action_pressed("up"):
		%player.global_position.y = max(%player.global_position.y - dist, up_limit)
	
	if Input.is_action_pressed("left"):
		%player.global_position.x = max(%player.global_position.x - dist, left_limit)

	if Input.is_action_pressed("right"):
		%player.global_position.x = min(%player.global_position.x + dist, right_limit)
