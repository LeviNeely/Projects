extends PanelContainer

@onready var cost: Label = %Cost
@onready var shader: ShaderMaterial = preload("res://Assets/Shaders/new_shader_material.tres")
@onready var button: Button = %Button

var viral: bool = false

#For calculating cost
var price_multiplier: float = 0.95

#Percentages for increasing money, followers, and sponsors
var money_multiplier: float
var follower_multiplier: float
var sponsor_multiplier: float

#Percentages for increasing chances
var sponsor_chance_multiplier: float
var viral_chance_multiplier: float
var rareness_chance_multiplier: float

#Special variables for this card only
var valid: bool = false
var multiplier: float = 3.0

func _ready() -> void:
	randomize()
	if randf() <= TurnData.viral_chance:
		viral = true
		price_multiplier = price_multiplier / 1.5
		multiplier *= 1.5
		material = shader
	cost.text = "$" + "%.2f" % (snapped((TurnData.start_money * price_multiplier), 0.01))

func play() -> void:
	if valid:
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
		for permanent in TurnData.permanents:
			if permanent != null:
				if permanent.money_multiplier:
					permanent.money_multiplier *= multiplier
				if permanent.follower_multiplier:
					permanent.follower_multiplier *= multiplier
				if permanent.sponsor_multiplier:
					permanent.sponsor_multiplier *= multiplier
				if permanent.sponsor_chance_multiplier:
					permanent.sponsor_chance_multiplier *= multiplier
				if permanent.viral_chance_multiplier:
					permanent.viral_chance_multiplier *= multiplier
				if permanent.rareness_chance_multiplier:
					permanent.rareness_chance_multiplier *= multiplier
				if permanent.has_method("multiply"):
					permanent.multiplier *= multiplier

func multiply() -> void:
	pass

func select() -> void:
	TurnData.num_legendary_posts += 1
	cost.text = ""
	button.text = "Delete Post"
	TurnData.emit_signal("move", self.get_parent())
	button.disconnect("pressed", select)
	button.connect("pressed", delete)
	var index: int = 0
	for post in TurnData.player_hand:
		if post == null:
			TurnData.player_hand[index] = self
			if index == 0:
				valid = true
			break
		index += 1

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
