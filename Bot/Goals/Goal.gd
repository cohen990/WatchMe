extends Node

class_name Goal

enum Type { None, Travel, Chase, Wait }


var type: int
var location: Vector2
var timing: float
var target: Node

var is_in_progress: bool

func _init(config = {}):
	type = get_or_default(config, "type", Type.None)
	location = get_or_default(config, "location", Vector2.ZERO)
	timing = get_or_default(config, "timing", 0)
	target = get_or_default(config, "target", null)
	is_in_progress = false

func _to_string():
	var name_of_goal_type = Type.keys()[type]
	
	print("Goal Type: " + name_of_goal_type + ", target: " + str(location))

func get_or_default(config, key, default):
	return default if not config.has(key) else config[key]
