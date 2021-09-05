extends Node

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func float_in_range(symmetric_range: float):
	return rng.randf_range(-symmetric_range, symmetric_range)
	
func float_in_range_asymmetric(lower_range: float, upper_range: float):
	return rng.randf_range(lower_range, upper_range)
	
func random_position(bounds: Bounds):
	var x = rng.randf_range(bounds.lower.x, bounds.upper.x)
	var y = rng.randf_range(bounds.lower.y, bounds.upper.y)
	print(bounds)
	return Vector2(x, y)

func randomise_direction_in_radians_cone(direction: Vector2, rads: float):
	var new_angle = rng.randf_range(-rads, rads)
	return direction.rotated(new_angle)
	
