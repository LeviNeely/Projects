extends Control

@onready var money_reward = %MoneyReward

func _ready() -> void:
	money_reward.instance()
