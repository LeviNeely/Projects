extends Control

@onready var sponsor_reward = %SponsorReward

func _ready() -> void:
	sponsor_reward.instance()
