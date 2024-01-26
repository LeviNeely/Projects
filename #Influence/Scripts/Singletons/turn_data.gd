extends Node

#Save/Load variables
const SAVE_FILE: String = "user://savefile.dat"
var data: Dictionary = {}

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
var sponsor_chance: float = 0.1
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
var num_viral_posts_posted: int = 0

#Education variables
var num_education_posts_read: int = 0
var num_ally_posts: int = 0

#Long-term variables
var finished_first_game: bool = false
var earned_badges: Dictionary = {
	"Trillionaire": false,
	"Crowdsourcing": false,
	"Penniless, Friendless": false,
	"Popular": false,
	"Sell-Out": false,
	"Capitalist Enabler": false,
	"Trend Setter": false,
	"Fumbled": false,
	"Capitalist Star": false,
	"Fortunate": false,
	"Bribee": false,
	"Educated": false,
	"Contradictory": false,
	"Conscientious Objector": false,
	"Lucky Ally": false,
	"Big Hit": false,
	"Household Name": false,
	"Makes Sense": false,
	"Trending": false,
	"Doing Capitalism Wrong": false,
	"Capitalism's Bitch": false,
	"Refusing to Engage": false,
	"Lucky Duck": false,
	"The World is Watching": false,
	"Overachiever": false
}

func _ready() -> void:
	update_thresholds()

func update_thresholds() -> void:
	common_threshold = threshold_modifier * exp((threshold_exponent_modifier * 0.0))
	normal_threshold = threshold_modifier * exp((threshold_exponent_modifier * 1.0))
	uncommon_threshold = threshold_modifier * exp((threshold_exponent_modifier * 2.0))
	rare_threshold = threshold_modifier * exp((threshold_exponent_modifier * 3.0))

func completely_reset() -> void:
	#Player stats
	start_money = 1.00
	money = 1.00
	follower_base = 10
	sponsors = 0

	#Gameplay stats
	sponsor_chance = 0.1
	viral_chance = 0.01

	#Post rarity thresholds
	threshold_modifier = 0.5
	common_threshold = 0.5
	normal_threshold = 0.8
	uncommon_threshold = 0.9
	rare_threshold = 0.97
	legendary_threshold = 1.0

	#Posting screen stats
	num_free_redraws = 2
	num_paid_redraws = 0
	num_common_posts = 0
	num_normal_posts = 0
	num_uncommon_posts = 0
	num_rare_posts = 0
	num_legendary_posts = 0
	num_viral_posts = 0

	#The player's hand
	player_hand = [
		null, 
		null, 
		null, 
		null, 
		null
	]

	#The player's permanents
	permanents = [
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
	double_permanents = false

	#Post-specific booleans
	one_guaranteed_viral_post = false
	all_posts_viral = false

	#Permanent-specific booleans
	sponsor_multiplier = 1

	#UI variables
	date = 1

	#Reward variables
	num_viral_posts_posted = 0

	#Education variables
	num_education_posts_read = 0
	num_ally_posts = 0

func deep_reset() -> void:
	finished_first_game = false
	earned_badges = {
		"Trillionaire": false,
		"Crowdsourcing": false,
		"Penniless, Friendless": false,
		"Popular": false,
		"Sell-Out": false,
		"Capitalist Enabler": false,
		"Trend Setter": false,
		"Fumbled": false,
		"Capitalist Star": false,
		"Fortunate": false,
		"Bribee": false,
		"Educated": false,
		"Contradictory": false,
		"Conscientious Objector": false,
		"Lucky Ally": false,
		"Big Hit": false,
		"Household Name": false,
		"Makes Sense": false,
		"Trending": false,
		"Doing Capitalism Wrong": false,
		"Capitalism's Bitch": false,
		"Refusing to Engage": false,
		"Lucky Duck": false,
		"The World is Watching": false,
		"Overachiever": false
	}

func save_data() -> void:
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	data = {
		#Player stats
		"start_money": start_money,
		"money": money,
		"follower_base": follower_base,
		"sponsors": sponsors,
		#Gameplay stats
		"sponsor_chance": sponsor_chance,
		"viral_chance": viral_chance,
		#Post rarity thresholds
		"threshold_modifier": threshold_modifier,
		#The player's permanents
		"permanents": permanents,
		"double_permanents": double_permanents,
		#Post-specific booleans
		"one_guaranteed_viral_post": one_guaranteed_viral_post,
		"all_posts_viral": all_posts_viral,
		#Permanent-specific booleans
		"sponsor_multiplier": sponsor_multiplier,
		#UI variables
		"date": date,
		#Reward variables
		"num_viral_posts_posted": num_viral_posts_posted,
		#Education variables
		"num_education_posts_read": num_education_posts_read,
		"num_ally_posts": num_ally_posts,
		#Long-term variables
		"finished_first_game": finished_first_game,
		"earned_badges": earned_badges
	}
	file.store_var(data)
	file = null

func load_data() -> void:
	var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	data = file.get_var()
	start_money = data.start_money
	money = data.money
	follower_base = data.follower_base
	sponsors = data.sponsors
	sponsor_chance = data.sponsor_chance
	viral_chance = data.viral_chance
	threshold_modifier = data.threshold_modifier
	permanents = data.permanents
	double_permanents = data.double_permanents
	one_guaranteed_viral_post = data.one_guaranteed_viral_post
	all_posts_viral = data.all_posts_viral
	sponsor_multiplier = data.sponsor_multiplier
	date = data.date
	num_viral_posts_posted = data.num_viral_posts_posted
	num_education_posts_read = data.num_education_posts_read
	num_ally_posts = data.num_ally_posts
	finished_first_game = data.finished_first_game
	earned_badges = data.earned_badges
	update_thresholds()
