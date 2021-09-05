extends Node

class_name Bounds

var lower: Vector2
var upper: Vector2

func _init(lower_bound: Vector2, upper_bound: Vector2):
	lower = lower_bound
	upper = upper_bound

func _to_string ():
	return "lower: (" + str(lower.x) + " " + str(lower.y) + "), upper: (" + str(upper.x) + " " + str(upper.y) + ")"
