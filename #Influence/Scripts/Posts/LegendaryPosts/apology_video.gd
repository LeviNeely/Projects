extends PanelContainer

@onready var cost: Label = %Cost
@onready var shader: ShaderMaterial = preload("res://Assets/Shaders/new_shader_material.tres")
@onready var button: Button = %Button


var viral: bool = false
var valid: bool = false
var price_multiplier: float = 0.6
var money_multiplier: float = 0.5
var follower_multiplier: float = 0.5
var sponsor_multiplier: float = 0.5

func _ready() -> void:
	randomize()
	if randf() <= TurnData.viral_chance:
		viral = true
		price_multiplier = price_multiplier / 1.5
		money_multiplier *= 1.5
		follower_multiplier *= 1.5
		sponsor_multiplier *= 1.5
		material = shader
	cost.text = "$" + "%.2f" % (snapped((TurnData.start_money * price_multiplier), 0.01))

func _process(delta) -> void:
	if TurnData.num_common_posts == 1 and TurnData.num_normal_posts == 1 and TurnData.num_uncommon_posts == 1 and TurnData.num_rare_posts == 1 and TurnData.num_legendary_posts == 1:
		valid = true

func play() -> void:
	if valid:
		TurnData.money += snapped((TurnData.money * money_multiplier), 0.01)
		TurnData.follower_base += round(TurnData.follower_base * follower_multiplier)
		TurnData.sponsors += round(TurnData.sponsors * sponsor_multiplier)
	else:
		return

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
