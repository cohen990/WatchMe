extends Node

class_name Goal

var type: int = GoalType.None
var location: Vector2 = Vector2.ZERO

func _init(goal_type: int, goal_location: Vector2):
	type = goal_type
	location = goal_location

func _to_string():
	var name_of_goal_type = GoalType.keys()[type]
	
	print("Goal Type: " + name_of_goal_type + ", target: " + str(location))
