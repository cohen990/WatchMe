extends Node

var bounds: Bounds = Bounds.new(Vector2(10,10), Vector2(1800,1000))
#var bounds: Bounds = Bounds.new(Vector2(10,10), Vector2(50,50))

func clamp_position(position: Vector2):
	var clamped_x = clamp(position.x, bounds.lower.x, bounds.upper.x)
	var clamped_y = clamp(position.y, bounds.lower.y, bounds.upper.y)
	return Vector2(clamped_x, clamped_y)
