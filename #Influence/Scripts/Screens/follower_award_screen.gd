extends Control

@onready var follower_reward = %FollowerReward

func _ready() -> void:
	follower_reward.instance()
