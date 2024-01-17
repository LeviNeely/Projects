extends PanelContainer

@onready var cost: Label = %Cost
@onready var cost_and_button: HBoxContainer = %CostAndButton
@onready var button: Button = %Button

var multiplier: float = 0.025

func _ready() -> void:
	var price: float = float(cost.text.replace("$", ""))
	if price > TurnData.money:
		button.disabled = true

func play() -> void:
	if TurnData.double_permanents:
		multiplier *= 2
	TurnData.threshold_modifier -= (TurnData.threshold_modifier * multiplier)
	TurnData.update_thresholds()

func buy() -> void:
	TurnData.money -= float(cost.text.replace("$", ""))
	change_button()
	TurnData.emit_signal("buy", self.get_parent())
	var index: int = 0
	for permanent in TurnData.permanents:
		if permanent == null:
			TurnData.permanents[index] = "res://Scenes/Permanents/UncommonPermanents/best_editing_software.tscn"
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
		if permanent == "res://Scenes/Permanents/UncommonPermanents/best_editing_software.tscn":
			TurnData.permanents.remove_at(index)
			TurnData.permanents.append(null)
			break
		index += 1
	TurnData.emit_signal("delete", self.get_parent())
	queue_free()
