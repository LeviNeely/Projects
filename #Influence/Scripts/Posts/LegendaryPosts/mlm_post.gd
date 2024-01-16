extends PanelContainer

@onready var cost: Label = %Cost
@onready var shader: ShaderMaterial = preload("res://Assets/Shaders/new_shader_material.tres")
@onready var button: Button = %Button

var viral: bool = false

#For calculating cost
var price_multiplier: float = 0.5

#Percentages for increasing money, followers, and sponsors
var money_multiplier: float
var follower_multiplier: float = 0.05
var sponsor_multiplier: float = -0.5

#Percentages for increasing chances
var sponsor_chance_multiplier: float
var viral_chance_multiplier: float
var rareness_chance_multiplier: float

func _ready() -> void:
	randomize()
	if randf() <= TurnData.viral_chance:
		viral = true
		price_multiplier = price_multiplier / 1.5
		follower_multiplier *= 1.5
		sponsor_multiplier *= 1.5
		material = shader
	cost.text = "$" + "%.2f" % (snapped((TurnData.money * price_multiplier), 0.01))

func play() -> void:
	TurnData.follower_base += round(TurnData.follower_base * follower_multiplier)
	var multiplier: int = round(0.5 * (pow((8 * TurnData.follower_base + 1), 0.5)) - 1)
	TurnData.money += TurnData.money * multiplier
	TurnData.sponsors += round(TurnData.sponsors * sponsor_multiplier)

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
