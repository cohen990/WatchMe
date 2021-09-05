extends Node2D

onready var BotScene = preload("res://Bot/Bot.tscn")
const NUM_BOTS = 20

func _ready():
	for i in NUM_BOTS:
		var bot = BotScene.instance()
		bot.position = Seed.random_position(Map.bounds)
		print(bot.position)
		self.add_child(bot)
