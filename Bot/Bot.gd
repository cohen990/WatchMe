extends KinematicBody2D

onready var Arrow = $Arrow

const EPSILON = 0.01
const VELOCITY = 100
const SEARCH_RANGE = 100

var velocity: Vector2


var goal: Goal = null
var last_position: Vector2 = Vector2.INF

var nearby_bots = []
var way_too_close_bots = []

func _physics_process(_delta):
	if(has_goal()):
		act()
	else:
		Arrow.visible = false
		find_goal()

func has_goal():
	return goal != null

func act():
	if(goal.type == GoalType.Travel):
		Arrow.visible = true
		last_position = self.position
		travel_to(goal.location)
	else:
		print("unknown goal type")
	check_if_achieved_goal()

func find_goal():
	var new_goal: Vector2
	if(nearby_bots.size() == 0):
		new_goal = Vector2(get_x_goal(), get_y_goal())
	else:
		new_goal = get_away_from_bots(nearby_bots)
	goal = TravelGoal.new(new_goal)

func get_x_goal():
	var target_x = self.position.x + Seed.float_in_range(SEARCH_RANGE)
	target_x = clamp(target_x, Map.bounds.lower.x, Map.bounds.upper.x)
	return target_x
	
func get_y_goal():
	var target_y = self.position.y + Seed.float_in_range(SEARCH_RANGE)
	target_y = clamp(target_y, Map.bounds.lower.y, Map.bounds.upper.y)
	return target_y
	
func get_away_from_bots(bots_to_get_away_from: Array):
	var added_vectors_of_distances_to_neighbours = Vector2.ZERO
	for bot in bots_to_get_away_from:
		added_vectors_of_distances_to_neighbours += self.position.direction_to(bot.position)
	var normalised = added_vectors_of_distances_to_neighbours.normalized()
	var angle = normalised.angle()
	var randomised_direction = Seed.randomise_direction_in_radians_cone(normalised, 1.5)
	var random_angle = randomised_direction.angle()
	var wants_to_run_to = self.position - (randomised_direction * SEARCH_RANGE)
	return Map.clamp_position(wants_to_run_to)

func travel_to(location: Vector2):
	var distance = self.position.distance_to(location)
	var direction = self.position.direction_to(location)
	velocity = self.move_and_slide(direction * VELOCITY * (min(distance, 1)))
	Arrow.rotation = direction.angle()

func check_if_achieved_goal():
	if(goal.type == GoalType.Travel):
		var distance_to_goal = self.position.distance_to(goal.location)
		if(distance_to_goal < EPSILON):
			goal = null


func _on_GettingCloseArea_body_entered(body):
	if(body == self):
		return
	nearby_bots.append(body)


func _on_GettingCloseArea_body_exited(body):
	nearby_bots.erase(body)


func _on_EmergencyArea_body_entered(body):
	if(body == self):
		return
	way_too_close_bots.append(body)	
	print("Stranger danger!")
	var new_goal = get_away_from_bots(way_too_close_bots)
	goal = TravelGoal.new(new_goal)


func _on_EmergencyArea_body_exited(body):
	print("bye stranger")
	way_too_close_bots.erase(body)
