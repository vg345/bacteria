extends Node2D

var plasmid = preload("res://scenes/plasmid.tscn")
var bacteria = preload("res://scenes/bacteria.tscn")

@onready var left_limit = %mark1.global_position.x + 50
@onready var right_limit = %mark2.global_position.x - 50
@onready var up_limit = %mark1.global_position.y + 50
@onready var down_limit = %mark2.global_position.y - 50

var plasmid_info:Dictionary

var dist = global.BASE_SPEED
var defense = global.DEFENSE
var toxin_gen = global.TOXIN_GEN
var toxin_res = global.TOXIN_RES
var inventory = global.INVENTORY
var total_spawns = global.spawns

func _ready():
	var json = FileAccess.get_file_as_string("res://data/plasmids.json")
	plasmid_info = JSON.parse_string(json)

func update():
	dist = global.BASE_SPEED * %player.dict["speed"]
	defense = global.DEFENSE * %player.dict["defense"]
	toxin_gen = global.TOXIN_GEN * %player.dict["toxin_gen"]
	toxin_res = global.TOXIN_RES * %player.dict["toxin_res"]
	%player.update()
	inventory = global.INVENTORY + %player.inventory_boost
	total_spawns = global.spawns + int(%player.net_boost/8)
	%stats.text = str(dist) + "\n" + str(defense) + "\n" + str(toxin_gen) + "\n" + str(toxin_res) + "\n" + str(inventory)


func _process(_delta):
	if Input.is_action_pressed("down"):
		%player.global_position.y = min(%player.global_position.y + dist, down_limit)
	
	if Input.is_action_pressed("up"):
		%player.global_position.y = max(%player.global_position.y - dist, up_limit)
	
	if Input.is_action_pressed("left"):
		%player.global_position.x = max(%player.global_position.x - dist, left_limit)

	if Input.is_action_pressed("right"):
		%player.global_position.x = min(%player.global_position.x + dist, right_limit)
	if global.pending:
		update()
		global.pending = false

func spawn():
	var new:Node
	var is_bacteria = false
	if global.spawned < 3:
		new = plasmid.instantiate()
	else:
		new = bacteria.instantiate()
		is_bacteria = true
	var x = randi() %  int(right_limit)
	var y = randi() % int(down_limit)
	new.global_position = Vector2(x,y)
	new.type = plasmid_info.keys().pick_random()
	if randi() % 100 < 25:
		new.negative = true
	new.modulate = Color(plasmid_info[new.type].color)
	if is_bacteria:
		new.setup(plasmid_info[new.type].path)
	%spawned.add_child(new)
	global.spawned += 1


func _on_spawn_timer_timeout() -> void:
	if %spawned.get_child_count() < total_spawns: 
		spawn()
		
