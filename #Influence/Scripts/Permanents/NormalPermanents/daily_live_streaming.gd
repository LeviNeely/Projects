extends PanelContainer

@onready var cost: Label = %Cost
@onready var cost_and_button: HBoxContainer = %CostAndButton
@onready var button: Button = %Button

var modifier: float = 0.01
const permanent_path: String = "res://Scenes/Permanents/NormalPermanents/daily_live_streaming.tscn"
var index: int = 0

func _ready() -> void:
	var price: float = float(cost.text.replace("$", ""))
	if price > TurnData.money:
		button.disabled = true

func play() -> void:
	if TurnData.double_permanents:
		modifier *= 2
	TurnData.follower_base += round(TurnData.follower_base * modifier)

func buy() -> void:
	TurnData.money -= float(cost.text.replace("$", ""))
	change_button()
	TurnData.emit_signal("buy", self.get_parent())
	var index: int = 0
	for permanent in TurnData.permanents:
		if permanent == null:
			TurnData.permanents[index] = permanent_path
			self.index = index
			break
		index += 1

func change_button() -> void:
	cost.text = ""
	button.text = "Delete"
	button.disconnect("pressed", buy)
	button.connect("pressed", Callable(self, "delete").bind(self))

func hide_cost_and_button() -> void:
	cost_and_button.visible = false

func delete(permanent_instance: Node) -> void:
	var index: int = TurnData.permanents.find(permanent_instance.permanent_path)
	if index != -1:
		TurnData.permanents[self.index] = null
		TurnData.emit_signal("delete", self.get_parent())
		permanent_instance.queue_free()
