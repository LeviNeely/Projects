extends PanelContainer

@onready var cost: Label = %Cost
@onready var save: VBoxContainer = %Save

var total_days: float = 30.0
var base_money_gained: float = 1.0 * (1.0 + (float(TurnData.date) / total_days))
var money: float

## Function called on instantiation
func _ready() -> void:
	save.visible = false

## Function called with the object is "instanced"
func instance() -> void:
	randomize()
	set_themes()

## Function to determine what theme and rewards the object should have based on chance
func set_themes() -> void:
	var money_chance: float = randf()
	if money_chance <= TurnData.common_threshold:
		self.set_theme_type_variation("CommonPanelContainer")
		money = calculate_money()
		cost.text = "$" + GlobalMethods.determine_money_amount(money)
	elif money_chance > TurnData.common_threshold and money_chance <= TurnData.normal_threshold:
		self.set_theme_type_variation("NormalPanelContainer")
		base_money_gained *= 2.0
		money = calculate_money()
		cost.text = "$" + GlobalMethods.determine_money_amount(money)
	elif money_chance > TurnData.normal_threshold and money_chance <= TurnData.uncommon_threshold:
		self.set_theme_type_variation("UncommonPanelContainer")
		base_money_gained *= 3.0
		money = calculate_money()
		cost.text = "$" + GlobalMethods.determine_money_amount(money)
	elif money_chance > TurnData.uncommon_threshold and money_chance <= TurnData.rare_threshold:
		self.set_theme_type_variation("RarePanelContainer")
		base_money_gained *= 4.0
		money = calculate_money()
		cost.text = "$" + GlobalMethods.determine_money_amount(money)
	else:
		self.set_theme_type_variation("LegendaryPanelContainer")
		base_money_gained *= 5.0
		money = calculate_money()
		cost.text = "$" + GlobalMethods.determine_money_amount(money)

## Function used to calculate how much money the player earned
func calculate_money() -> float:
	var money_gained: float = base_money_gained * float(TurnData.follower_base) * float(TurnData.sponsors + 1) * (float(TurnData.date) / total_days)
	return snapped(money_gained, 0.01)

## Function used to add the money to the player's money and change the scene
func add_money() -> void:
	TurnData.money += money
	get_tree().change_scene_to_file("res://Scenes/Screens/permanent_screen.tscn")
