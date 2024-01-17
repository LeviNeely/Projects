extends Node

#Signals
signal move(parent_node)
signal remove(parent_node)
signal buy(parent_node)
signal delete(parent_node)

#Player stats
var start_money: float = 1.00
var money: float = 1.00
var follower_base: int = 10
var sponsors: int = 0

#Gameplay stats
var sponsor_chance: float = 0.05
var viral_chance: float = 0.01

#Post rarity thresholds
var threshold_modifier: float = 0.5
const threshold_exponent_modifier: float = 0.221
var common_threshold: float = 0.5
var normal_threshold: float = 0.8
var uncommon_threshold: float = 0.9
var rare_threshold: float = 0.97
var legendary_threshold: float = 1.0

#Posting screen stats
var num_free_redraws: int = 2
var num_paid_redraws: int = 0
var num_common_posts: int = 0
var num_normal_posts: int = 0
var num_uncommon_posts: int = 0
var num_rare_posts: int = 0
var num_legendary_posts: int = 0
var num_viral_posts: int = 0

#The player's hand
var player_hand: Array = [
	null, 
	null, 
	null, 
	null, 
	null
]

#The player's permanents
var permanents: Array = [
	null, 
	null, 
	null,
	null,
	null,
	null,
	null,
	null,
	null
]
var double_permanents: bool = false

#Post-specific booleans
var one_guaranteed_viral_post: bool = false
var all_posts_viral: bool = false

#Permanent-specific booleans
var sponsor_multiplier: int = 1

#UI variables
var date: int = 1

#Reward variables
var popularity: float = 1.0

#Education variables
var num_education_posts_read: int = 0

func _ready() -> void:
	update_thresholds()

func update_thresholds() -> void:
	common_threshold = threshold_modifier * exp((threshold_exponent_modifier * 0.0))
	normal_threshold = threshold_modifier * exp((threshold_exponent_modifier * 1.0))
	uncommon_threshold = threshold_modifier * exp((threshold_exponent_modifier * 2.0))
	rare_threshold = threshold_modifier * exp((threshold_exponent_modifier * 3.0))
