extends PanelContainer

@onready var cost: Label = %Cost
@onready var shader: ShaderMaterial = preload("res://Assets/Shaders/new_shader_material.tres")
@onready var button: Button = %Button

var viral: bool = false

#For calculating cost
var price_multiplier: float = 0.35

#Percentages for increasing money, followers, and sponsors
var money_multiplier: float
var follower_multiplier: float
var sponsor_multiplier: float

#Percentages for increasing chances
var sponsor_chance_multiplier: float = 0.05
var viral_chance_multiplier: float
var rareness_chance_multiplier: float

func _ready() -> void:
	randomize()
	if randf() <= TurnData.viral_chance:
		viral = true
		price_multiplier = price_multiplier / 1.5
		sponsor_chance_multiplier *= 1.5
		material = shader
	cost.text = determine_cost(snapped((TurnData.start_money * price_multiplier), 0.01))

func determine_cost(money: float) -> String:
	if money <= 999999.99:
		return "$%.2f" % money
	else:
		var exponent: int = 0
		while money >= 10.0:
			money /= 10.0
			exponent += 1
		var mantissa: float = snapped(money, 0.01)
		return "$%.2fe%d" % [mantissa, exponent]

func play() -> void:
	if TurnData.follower_base < 1000:
		follower_multiplier = 0.25
		if viral:
			follower_multiplier *= 1.5
		TurnData.follower_base += round(TurnData.follower_base * follower_multiplier)
	else:
		follower_multiplier = 0.15
		if viral:
			follower_multiplier *= 1.5
		TurnData.follower_base += round(TurnData.follower_base * follower_multiplier)
		TurnData.sponsor_chance += TurnData.sponsor_chance * sponsor_chance_multiplier

func select() -> void:
	TurnData.num_rare_posts += 1
	cost.text = ""
	button.text = "Delete Post"
	TurnData.emit_signal("move", self.get_parent())
	button.disconnect("pressed", select)
	button.connect("pressed", delete)
	var index: int = 0
	for post in TurnData.player_hand:
		if post == null:
			TurnData.player_hand[index] = self
			break
		index += 1

func delete() -> void:
	TurnData.num_rare_posts -= 1
	var index: int = 0
	for post in TurnData.player_hand:
		if post == self:
			TurnData.player_hand[index] = null
			break
		index += 1
	TurnData.emit_signal("remove", self.get_parent())
	queue_free()
