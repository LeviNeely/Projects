extends PanelContainer

@onready var cost: Label = %Cost
@onready var shader: ShaderMaterial = preload("res://Assets/Shaders/new_shader_material.tres")
@onready var button: Button = %Button

var viral: bool = false

#For calculating cost
var price_multiplier: float = 0.0

#Percentages for increasing money, followers, and sponsors
var money_multiplier: float = 0.01
var follower_multiplier: float
var sponsor_multiplier: float

#Percentages for increasing chances
var sponsor_chance_multiplier: float
var viral_chance_multiplier: float
var rareness_chance_multiplier: float

func _ready() -> void:
	randomize()
	if randf() <= TurnData.viral_chance:
		viral = true
		price_multiplier = price_multiplier / 1.5
		money_multiplier *= 1.5
		material = shader
	cost.text = "$" + "%.2f" % (snapped((TurnData.start_money * price_multiplier), 0.01))

func play() -> void:
	var hand_size: int = 0
	for post in TurnData.player_hand:
		if post != null:
			hand_size += 1
	match hand_size:
		5:
			pass
		4:
			TurnData.money += snapped((TurnData.money * money_multiplier), 0.01)
		3:
			money_multiplier *= 2
			TurnData.money += snapped((TurnData.money * money_multiplier), 0.01)
		2:
			money_multiplier *= 3
			TurnData.money += snapped((TurnData.money * money_multiplier), 0.01)
		1:
			money_multiplier *= 4
			TurnData.money += snapped((TurnData.money * money_multiplier), 0.01)

func select() -> void:
	TurnData.num_common_posts += 1
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
	TurnData.num_common_posts -= 1
	var index: int = 0
	for post in TurnData.player_hand:
		if post == self:
			TurnData.player_hand[index] = null
			break
		index += 1
	TurnData.emit_signal("remove", self.get_parent())
	queue_free()
