extends PanelContainer

@onready var cost: Label = %Cost
@onready var shader: ShaderMaterial = preload("res://Assets/Shaders/new_shader_material.tres")
@onready var button: Button = %Button

var viral: bool = false

#For calculating cost
var price_multiplier: float = 0.6

#Percentages for increasing money, followers, and sponsors
var money_multiplier: float
var follower_multiplier: float
var sponsor_multiplier: float

#Percentages for increasing chances
var sponsor_chance_multiplier: float
var viral_chance_multiplier: float
var rareness_chance_multiplier: float

#Special stat for this card only
var multiplier: float = 2.0

func _ready() -> void:
	randomize()
	if randf() <= TurnData.viral_chance:
		viral = true
		price_multiplier = price_multiplier / 1.5
		multiplier *= 1.5
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
	for post in TurnData.player_hand:
		if post != self and post != null:
			if post.money_multiplier:
				post.money_multiplier *= multiplier
			if post.follower_multiplier:
				post.follower_multiplier *= multiplier
			if post.sponsor_multiplier:
				post.sponsor_multiplier *= multiplier
			if post.sponsor_chance_multiplier:
				post.sponsor_chance_multiplier *= multiplier
			if post.viral_chance_multiplier:
				post.viral_chance_multiplier *= multiplier
			if post.rareness_chance_multiplier:
				post.rareness_chance_multiplier *= multiplier
			if post.has_method("multiply"):
				post.multiplier *= multiplier

func place_post() -> void:
	var first_null_index = TurnData.player_hand.find(null)
	if first_null_index != -1:
		for i in range(first_null_index, 0, -1):
			TurnData.player_hand[i] = TurnData.player_hand[i - 1]
	else:
		for i in range(TurnData.player_hand.size() - 1, 0, -1):
			TurnData.player_hand[i] = TurnData.player_hand[i - 1]
	TurnData.player_hand[0] = self

func multiply() -> void:
	pass

func select() -> void:
	TurnData.num_legendary_posts += 1
	cost.text = ""
	button.text = "Delete Post"
	TurnData.emit_signal("move", self.get_parent())
	button.disconnect("pressed", select)
	button.connect("pressed", delete)
	place_post()

func delete() -> void:
	TurnData.num_legendary_posts -= 1
	var index: int = 0
	for post in TurnData.player_hand:
		if post == self:
			TurnData.player_hand[index] = null
			break
		index += 1
	TurnData.emit_signal("remove", self.get_parent())
	queue_free()
