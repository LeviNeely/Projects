extends PanelContainer

@onready var cost: Label = %Cost
@onready var cost_and_button: HBoxContainer = %CostAndButton
@onready var button: Button = %Button

var modifier: float = 0.05

func _ready() -> void:
	var price: float = float(cost.text.replace("$", ""))
	if price > TurnData.money:
		button.disabled = true

func play() -> void:
	if TurnData.double_permanents:
		modifier *= 2
	TurnData.money += snapped((TurnData.money * (modifier * TurnData.sponsors)), 0.01)

func buy() -> void:
	TurnData.money -= float(cost.text.replace("$", ""))
	change_button()
	TurnData.emit_signal("buy", self.get_parent())
	var index: int = 0
	for permanent in TurnData.permanents:
		if permanent == null:
			TurnData.permanents[index] = "res://Scenes/Permanents/RarePermanents/endorsement_deal.tscn"
			break
		index += 1

func change_button() -> void:
	cost.text = ""
	button.text = "Delete"
	button.disconnect("pressed", buy)
	button.connect("pressed", delete)

func hide_cost_and_button() -> void:
	cost_and_button.visible = false

func delete() -> void:
	var index: int = 0
	for permanent in TurnData.permanents:
		if permanent == "res://Scenes/Permanents/RarePermanents/endorsement_deal.tscn":
			TurnData.permanents.remove_at(index)
			TurnData.permanents.append(null)
			break
		index += 1
	TurnData.emit_signal("delete", self.get_parent())
	queue_free()
