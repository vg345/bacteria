extends Node2D

var plasmid = preload("res://scenes/plasmid.tscn")
var bacteria = preload("res://scenes/bacteria.tscn")

@export var under_attack = false
var resolved = false
@onready var left_limit = %mark1.global_position.x + 50
@onready var right_limit = %mark2.global_position.x - 50
@onready var up_limit = %mark1.global_position.y + 50
@onready var down_limit = %mark2.global_position.y - 50
@onready var pts = {%pt1: Vector2(1,0), %pt2: Vector2(0,1), %pt3: Vector2(0,-1)}


var plasmid_info:Dictionary

var dist = global.BASE_SPEED
var defense = global.DEFENSE
var toxin_gen = global.TOXIN_GEN
var toxin_res = global.TOXIN_RES
var inventory = global.INVENTORY
var total_spawns = global.spawns

var one_time = true
var attack_type:String
var next_attack:String

func _ready():
	var json = FileAccess.get_file_as_string("res://data/plasmids.json")
	plasmid_info = JSON.parse_string(json)
	next_attack = plasmid_info.keys().pick_random()

func update():
	dist = global.BASE_SPEED * %player.dict["speed"]
	%SpeedValue.text = str(dist)
	if dist <= 0:
		game_over()
	defense = global.DEFENSE * %player.dict["defense"]
	%DefenseValue.text = str(defense)
	toxin_gen = global.TOXIN_GEN * %player.dict["toxin_gen"]
	%ToxinGenValue.text = str(toxin_gen)
	toxin_res = global.TOXIN_RES * %player.dict["toxin_res"]
	%ToxinResValue.text = str(toxin_res)
	%player.update()
	inventory = global.INVENTORY + %player.inventory_boost
	total_spawns = global.spawns + int(%player.net_boost/8)
	

func _process(_delta):
	if global.controls and one_time:
		%Controls.visible = true
		one_time = false
	if !global.game_over:
	
		%healthProgress.value = global.health
		if global.health > 40:
			%healthProgress.modulate = Color("6fd250") 
		elif global.health > 20:
			%healthProgress.modulate = Color("fd9d00")
		else:
			%healthProgress.modulate = Color("fd3100") 
		if global.health <= 0 and !global.game_over:
			game_over()
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
	new.type = plasmid_info.keys().pick_random()
	if randi() % 100 < 25:
		new.negative = true
	new.modulate = Color(plasmid_info[new.type].color)
	if !is_bacteria:
		var x = randi() %  int(right_limit)
		var y = randi() % int(down_limit)
		new.global_position = Vector2(x,y)
	else:
		var new_pt = pts.keys().pick_random()
		new.global_position = new_pt.global_position
		new.direction = pts[new_pt].rotated(deg_to_rad((randi() % 90) - 45))

	if is_bacteria:
		new.setup(plasmid_info[new.type].path)
	%spawned.add_child(new)
	global.spawned += 1


func _on_spawn_timer_timeout() -> void:
	if %spawned.get_child_count() < total_spawns: 
		spawn()


func _on_despawn_timer_timeout() -> void:
	for child in %spawned.get_children():
		var pos = child.global_position
		var out_of_limits = pos.x > right_limit + 50 or pos.x < left_limit - 50 or pos.y > down_limit + 50 or pos.y < up_limit - 50
		if out_of_limits and child.can_dequeue:
			child.queue_free()

func game_over():
	%spawnTimer.stop()
	%despawnTimer.stop()
	global.game_over = true
	%bg2.visible = true
	await %player.die()
	%AnimationPlayerStart.play_backwards("start")
	await %AnimationPlayerStart.animation_finished
	%gameOver.visible = true
	

func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_mute_button_pressed() -> void:
	pass # Replace with function body.


func _on_start_button_pressed() -> void:
	global.health = 100
	global.game_over = false
	global.spawned = 0
	global.spawns = 3
	global.pending = true
	global.high_score = max(global.score, global.high_score)
	global.score = 0
	%highscore.text = str(int(global.high_score))
	%update.modulate = Color(plasmid_info[next_attack].color)
	%startButton.visible = false
	%AnimationPlayerStart.play("start")
	await %AnimationPlayerStart.animation_finished
	%bg2.visible = false
	%spawnTimer.start()
	%despawnTimer.start()


func _on_controls_button_pressed() -> void:
	if %Controls.visible:
		%Controls.visible = false
		global.controls = false
	else:
		%Controls.visible = true
		global.controls = true


func _on_up_pressed() -> void:
	if !global.game_over:
		%player.global_position.y = max(%player.global_position.y - dist, up_limit)


func _on_down_pressed() -> void:
	if !global.game_over:
		%player.global_position.y = min(%player.global_position.y + dist, down_limit)


func _on_left_pressed() -> void:
	if !global.game_over:
		%player.global_position.x = max(%player.global_position.x - dist, left_limit)


func _on_right_pressed() -> void:
	if !global.game_over:
		%player.global_position.x = min(%player.global_position.x + dist, right_limit)


func _on_attack_timer_timeout() -> void:
	if under_attack and !resolved:
		var prop = next_attack
		attack_type = prop
		next_attack = plasmid_info.keys().pick_random()
		var vec3 = Color.from_string(plasmid_info[prop]["color"], Color("ffffff"))
		print(vec3)
		%player.spoke_attack_color = Color(plasmid_info[prop].color)
		%attackShader.material.set_shader_parameter("random_col", Vector3(vec3.r, vec3.g, vec3.b))
		%attackShader.visible = true
		%AnimationPlayerAttack.play("attack")
		%attackOverTimer.start()
		%attackTimer.start()
		under_attack = false
		resolved = true

func _on_attack_over_timer_timeout() -> void:
	for i in %spawned.get_children():
		if i.type != attack_type:
			i.queue_free()
	%player.attack()
	for item in %player.dict.keys():
		if item != attack_type:
			global.score += %player.dict[item] / 3
			%player.dict[item] = 1
	%attackShader.visible = false
	resolved = false
	%score.text = str(int(global.score))

func update_score():
	%score.text = str(int(global.score))
	%highscore.text = str(int(global.high_score))
	
	
