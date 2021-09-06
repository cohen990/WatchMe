extends Node2D

onready var BotScene = preload("res://Bot/Bot.tscn")
const NUM_BOTS = 200

func _ready():
	for i in NUM_BOTS:
		var bot = BotScene.instance()
		bot.position = Seed.random_position(Map.bounds)
		self.add_child(bot)
