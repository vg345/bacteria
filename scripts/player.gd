extends Node2D

# multipliers
@export var dict = {"defense":1, "toxin_gen":1, "toxin_res":1, "speed":1, "health": 0}
@export var net_boost = 1
# added
@export var inventory_boost = 0
@export var latest_steals = []
@export var spoke_attack_color:Color

var plasmid_info: Dictionary
var spoke_tex = preload("res://assets/type7.png")

func _ready():
	var json = FileAccess.get_file_as_string("res://data/plasmids.json")
	plasmid_info = JSON.parse_string(json)

func update():
	net_boost = 0
	for i in dict.keys():
		net_boost += dict[i]

func _on_area_2d_area_entered(area: Area2D) -> void:
	if %spokes.get_child_count() < global.INVENTORY + inventory_boost:
		if area.is_in_group("plasmid") or area.is_in_group("bacteria"):
			var plasmid = area.get_parent()
			var sub = plasmid.negative
			if sub:
				dict[plasmid.type] -= plasmid_info[plasmid.type].level_up
				global.score -= 1
			else:
				dict[plasmid.type] += plasmid_info[plasmid.type].level_up
				global.score += 1
			if plasmid.type == "health":
				if sub:
					global.health -= 30
					global.score -= 1
				else:
					global.health = min(global.health + 30, 100)
					global.score += 1
			global.pending = true
			var spoke =  Sprite2D.new() 
			spoke.texture = spoke_tex
			#spoke.modulate = plasmid_info[plasmid.type].color
			if !sub and plasmid.type != "health":
				spoke.modulate = Color(plasmid_info[plasmid.type].color)
				%spokes.add_child(spoke)
				latest_steals.append(plasmid.type)
			update_rotation()
			if area.is_in_group("plasmid"):
				plasmid.can_dequeue= true

	if area.is_in_group("bacteria"):
		global.health -= 10 - (global.DEFENSE * dict["defense"])/100
	$"..".update_score()
			

func _process(delta):
	if !global.game_over:
		%spokes.rotate(deg_to_rad(50) * delta)


func update_rotation():
	var total = %spokes.get_child_count()
	for i in range(total):
		%spokes.get_child(i).rotation = deg_to_rad(360) * i / total
	if %spokes.get_child_count() == 8:
		$"..".under_attack = true

func attack():
	for child in %spokes.get_children():
		if child.modulate != spoke_attack_color:
			child.queue_free()

func die():
	%AnimationPlayerDeath.play("die")
	await %AnimationPlayerDeath.animation_finished
