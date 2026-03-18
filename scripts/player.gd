extends Node2D

# multipliers
@export var dict = {"defense":1, "toxin_gen":1, "toxin_res":1, "speed":1}

@export var net_boost = 1
# added
@export var inventory_boost = 0

var plasmid_info: Dictionary
var type5 = preload("res://assets/type3.png")

func _ready():
	var json = FileAccess.get_file_as_string("res://data/plasmids.json")
	plasmid_info = JSON.parse_string(json)

func update():
	net_boost = 0
	for i in dict.keys():
		net_boost += dict[i]

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("plasmid") and %spokes.get_child_count() < global.INVENTORY + inventory_boost:
		var plasmid = area.get_parent()
		var sub = plasmid.negative
		if sub:
			dict[plasmid.type] -= 0.5
		else:
			dict[plasmid.type] += 0.5
		global.pending = true
		plasmid.can_dequeue= true
		var spoke =  Sprite2D.new() 
		spoke.texture = type5
		#spoke.modulate = plasmid_info[plasmid.type].color
		%spokes.add_child(spoke)
		update_rotation()
	if area.is_in_group("bacteria"):
		global.health -= 10


func update_rotation():
	var total = %spokes.get_child_count()
	for i in range(total):
		%spokes.get_child(i).rotation = deg_to_rad(360) * i / total
