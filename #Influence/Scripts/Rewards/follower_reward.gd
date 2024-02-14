extends PanelContainer

@onready var cost: Label = %Cost
@onready var save: VBoxContainer = %Save

var base_followers_gained: int = 1

## Function called on intantiation
func _ready() -> void:
	save.visible = false

## Function called when the object is "initialized"
func instance() -> void:
	randomize()
	set_themes()

## Function that changes the themes of the object and the amount of followers awarded based on chance
func set_themes() -> void:
	var follower_chance: float = randf()
	var followers: int
	if follower_chance <= TurnData.common_threshold:
		self.set_theme_type_variation("CommonPanelContainer")
		followers = calculate_followers()
		cost.text = str(followers)
	elif follower_chance > TurnData.common_threshold and follower_chance <= TurnData.normal_threshold:
		self.set_theme_type_variation("NormalPanelContainer")
		base_followers_gained *= 2
		followers = calculate_followers()
		cost.text = str(followers)
	elif follower_chance > TurnData.normal_threshold and follower_chance <= TurnData.uncommon_threshold:
		self.set_theme_type_variation("UncommonPanelContainer")
		base_followers_gained *= 3
		followers = calculate_followers()
		cost.text = str(followers)
	elif follower_chance > TurnData.uncommon_threshold and follower_chance <= TurnData.rare_threshold:
		self.set_theme_type_variation("RarePanelContainer")
		base_followers_gained *= 4
		followers = calculate_followers()
		cost.text = str(followers)
	else:
		self.set_theme_type_variation("LegendaryPanelContainer")
		base_followers_gained *= 5
		followers = calculate_followers()
		cost.text = str(followers)

## Function that calculates how many followers the player will gain
func calculate_followers() -> int:
	var total_days: int = 30
	var followers_gained: int = base_followers_gained + round(base_followers_gained * (1.0 + (TurnData.date / total_days)))
	return followers_gained

## Function that adds the followers to the player's follower base and changes the scene
func add_followers() -> void:
	TurnData.follower_base += int(cost.text)
	var chance: float = randf()
	if chance < TurnData.sponsor_chance:
		get_tree().change_scene_to_file("res://Scenes/Screens/sponsor_award_screen.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/Screens/money_award_screen.tscn")
