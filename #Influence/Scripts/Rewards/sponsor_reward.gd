extends PanelContainer

@onready var cost: Label = %Cost
@onready var save: VBoxContainer = %Save

var base_sponsors_gained: int = 1

func _ready() -> void:
	save.visible = false

func instance() -> void:
	randomize()
	set_themes()

func set_themes() -> void:
	var sponsor_chance: float = randf()
	var sponsors: int
	if sponsor_chance <= TurnData.common_threshold:
		self.set_theme_type_variation("CommonPanelContainer")
		sponsors = calculate_sponsors()
		cost.text = str(sponsors)
	elif sponsor_chance > TurnData.common_threshold and sponsor_chance <= TurnData.normal_threshold:
		self.set_theme_type_variation("NormalPanelContainer")
		base_sponsors_gained *= 2
		sponsors = calculate_sponsors()
		cost.text = str(sponsors)
	elif sponsor_chance > TurnData.normal_threshold and sponsor_chance <= TurnData.uncommon_threshold:
		self.set_theme_type_variation("UncommonPanelContainer")
		base_sponsors_gained *= 3
		sponsors = calculate_sponsors()
		cost.text = str(sponsors)
	elif sponsor_chance > TurnData.uncommon_threshold and sponsor_chance <= TurnData.rare_threshold:
		self.set_theme_type_variation("RarePanelContainer")
		base_sponsors_gained *= 4
		sponsors = calculate_sponsors()
		cost.text = str(sponsors)
	else:
		self.set_theme_type_variation("LegendaryPanelContainer")
		base_sponsors_gained *= 5
		sponsors = calculate_sponsors()
		cost.text = str(sponsors)

func calculate_sponsors() -> int:
	var total_days: int = 30
	var sponsors_gained: int = base_sponsors_gained + round(base_sponsors_gained * (1.0 + (TurnData.date / total_days) + (TurnData.sponsors / TurnData.follower_base)))
	if TurnData.sponsor_multiplier != 1:
		sponsors_gained *= TurnData.sponsor_multiplier
		TurnData.sponsor_multiplier = 1
	return sponsors_gained

func add_sponsors() -> void:
	TurnData.sponsors += int(cost.text)
	get_tree().change_scene_to_file("res://Scenes/Screens/money_award_screen.tscn")
