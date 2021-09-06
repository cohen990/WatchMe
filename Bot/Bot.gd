extends KinematicBody2D

onready var Arrow = $DirectionArrow
onready var BotClock = $BotClock
onready var Bite = $Bite
onready var BiteArea = $Bite/BiteArea
onready var KillCountLabel = $KillCount
onready var GettingCloseArea = $GettingCloseArea
onready var HungerLabel = $Hunger

const DEBUG = false

const EPSILON = 0.5
const VELOCITY = 100
const AGGRESSIVE_VELOCITY_MULTIPLIER = 1.1
const DEFAULT_VELOCITY_MULTIPLIER = 1
const SEARCH_RANGE = 100
const DEFAULT_DAMAGE = 5

var velocity: Vector2
var velocity_multiplier = DEFAULT_VELOCITY_MULTIPLIER


var goal: Goal
var last_position: Vector2 = Vector2.INF
var stuck_ticks = 0

var nearby_bots = []
var way_too_close_bots = []
var neighbour_arrows = {}
var aggressive = false

var health = 10
var kill_count = 0
var damage = DEFAULT_DAMAGE

var hunger = 0

onready var NeighbourArrow = load("res://Bot/NeighbourArrow.tscn")

func _physics_process(_delta):
	if(stuck_ticks > 10):
		goal = null
		stuck_ticks = 0
	if(has_goal()):
		act()
	else:
		if(DEBUG):
			Arrow.visible = false
		find_goal()
	if(DEBUG):
		for neighbour in neighbour_arrows.keys():
			var arrow = neighbour_arrows[neighbour]
			var direction = self.position.direction_to(neighbour.position)
			arrow.rotation = direction.angle()

func has_goal():
	return goal != null

func act():
	if(goal.type == Goal.Type.Travel):
		if(DEBUG):
			Arrow.visible = true
		travel_to(goal.location)
	elif(goal.type == Goal.Type.Wait):
		wait()
	elif(goal.type == Goal.Type.Chase):
		chase()
	else:
		return
	check_if_achieved_goal()

func find_goal():
	if(nearby_bots.size() == 0):
		if(Seed.random_float() > 0.2):
			var new_goal = Vector2(get_x_goal(), get_y_goal())
			goal = TravelGoal.new(new_goal)
		else:
			goal = WaitGoal.new(Seed.random_float() * 2 + 1)
	else:
		if(Seed.random_float() < 0.1 * (hunger)):
			var target = closest(nearby_bots)
			goal = ChaseGoal.new(target, Seed.random_float() * 2 + 1)
		else:
			var new_goal = get_away_from_bots(nearby_bots)
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
	var randomised_direction = Seed.randomise_direction_in_radians_cone(normalised, 1.5)
	var wants_to_run_to = self.position - (randomised_direction * SEARCH_RANGE)
	return Map.clamp_position(wants_to_run_to)

func travel_to(location: Vector2):
	var distance = self.position.distance_to(location)
	var direction = self.position.direction_to(location)
	velocity = self.move_and_slide(direction * VELOCITY * velocity_multiplier * (min(distance, 1)))
	if(velocity.length_squared() < EPSILON):
		stuck_ticks += 1
	else:
		stuck_ticks = 0
	Bite.rotation = direction.angle()
	if(DEBUG):
		Arrow.rotation = direction.angle()

func check_if_achieved_goal():
	if(goal == null):
		return
	if(goal.type == Goal.Type.Travel):
		var distance_to_goal = self.position.distance_to(goal.location)
		if(distance_to_goal < EPSILON):
			goal = null

func wait():
	if(goal.is_in_progress and BotClock.is_stopped()):
		goal = null
		return
	if(BotClock.is_stopped()):
		BotClock.start(goal.timing)
		BotClock.one_shot = true
		goal.is_in_progress = true

func chase():
	var target = goal.target
	if(not is_instance_valid(target)):
		end_chase()
		return
	if(goal.is_in_progress and BotClock.is_stopped()):
		end_chase()
		return
	if(BotClock.is_stopped()):
		BotClock.start(goal.timing)
		BotClock.one_shot = true
		goal.is_in_progress = true
		start_aggression()
	travel_to(target.position)

func closest(bots: Array):
	var closest: Node = null
	var minimum_distance = INF
	for bot in bots:
		var distance = self.position.distance_to(bot.position)
		if(distance < minimum_distance):
			minimum_distance = distance
			closest = bot
	return closest
	

func take_damage(damage: float):
	health -= damage
	if(health < 0):
		self.queue_free()
	return health

func start_aggression():
	aggressive = true
	Bite.visible = true
	BiteArea.set_deferred("monitoring", true)
	velocity_multiplier = AGGRESSIVE_VELOCITY_MULTIPLIER * pow((kill_count + 1), 0.5)
	
func end_aggression():
	aggressive = false
	Bite.visible = false
	BiteArea.set_deferred("monitoring", false)
	velocity_multiplier = DEFAULT_VELOCITY_MULTIPLIER
	
func end_chase():
	end_aggression()
	BotClock.stop()
	goal = null

func _on_GettingCloseArea_body_entered(body):
	if(body == self):
		return
	nearby_bots.append(body)
	if(DEBUG):
		var arrow = NeighbourArrow.instance()
		self.add_child(arrow)
		neighbour_arrows[body] = arrow


func _on_GettingCloseArea_body_exited(body):
	nearby_bots.erase(body)
	if(DEBUG):
		var arrow = neighbour_arrows[body]
		arrow.free()
		neighbour_arrows.erase(body)


func _on_EmergencyArea_body_entered(body):
	if(body == self):
		return
	way_too_close_bots.append(body)
	if(not aggressive):
		var new_goal = get_away_from_bots(way_too_close_bots)
		goal = TravelGoal.new(new_goal)


func _on_EmergencyArea_body_exited(body):
	way_too_close_bots.erase(body)


func _on_BiteArea_body_entered(body):
	if(body == self):
		return
	var enemy_health = body.take_damage(damage)
	health += 1
	hunger = max(hunger - damage, 0)
	HungerLabel.text = str(hunger)
	if(enemy_health < 0):
		kill_count += 1
		KillCountLabel.text = str(kill_count)
		damage = DEFAULT_DAMAGE * (kill_count + 1)
	end_chase()


func _on_HungerTimer_timeout():
	hunger += 1
	GettingCloseArea.scale *= pow((hunger + 1), 0.5)
	
	HungerLabel.text = str(hunger)
