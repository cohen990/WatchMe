extends Node

var bounds: Bounds = Bounds.new(Vector2(10,10), Vector2(1000,500))
#var bounds: Bounds = Bounds.new(Vector2(10,10), Vector2(100,50))

func clamp_position(position: Vector2):
	var clamped_x = clamp(position.x, bounds.lower.x, bounds.upper.x)
	var clamped_y = clamp(position.x, bounds.lower.y, bounds.upper.y)
	return Vector2(clamped_x, clamped_y)
