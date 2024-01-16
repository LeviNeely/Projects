extends Control

#Permanent selection area variables
@onready var permanent_1: PanelContainer = %Permanent1
@onready var permanent_2: PanelContainer = %Permanent2
@onready var permanent_3: PanelContainer = %Permanent3
@onready var slots: Array[PanelContainer] = [
	permanent_1,
	permanent_2,
	permanent_3
]

#Permanent grid area variables
@onready var grid_container: GridContainer = %GridContainer
@onready var passive_1: PanelContainer = %Passive1
@onready var passive_2: PanelContainer = %Passive2
@onready var passive_3: PanelContainer = %Passive3
@onready var passive_4: PanelContainer = %Passive4
@onready var passive_5: PanelContainer = %Passive5
@onready var passive_6: PanelContainer = %Passive6
@onready var passive_7: PanelContainer = %Passive7
@onready var passive_8: PanelContainer = %Passive8
@onready var passive_9: PanelContainer = %Passive9

#Data variables
@onready var money_amount: Label = %MoneyAmount
@onready var post_chance_value: Label = %PostChanceValue
@onready var follower_amount: Label = %FollowerAmount
@onready var virality_chance_value: Label = %ViralityChanceValue
@onready var sponsors_amount: Label = %SponsorsAmount
@onready var sponsor_chance_value: Label = %SponsorChanceValue

#Permanent names
const common_permanents: Array[String] = [
	"res://Scenes/Permanents/CommonPermanents/basic_editing_software.tscn",
	"res://Scenes/Permanents/CommonPermanents/basic_trending_page.tscn",
	"res://Scenes/Permanents/CommonPermanents/money_management_app.tscn",
	"res://Scenes/Permanents/CommonPermanents/social_media_workshop.tscn"
]
const normal_permanents: Array[String] = []
const uncommon_permanents: Array[String] = []
const rare_permanents: Array[String] = []
const legendary_permanents: Array[String] = []

#Random variables
var available_permanent_slots: Array[PanelContainer] = []
var num_permanents: int = 0
var hide_buttons: bool = false

func _ready() -> void:
	randomize()
	connect_signals()
	update_data()
	draw_permanents()
	fill_in_permanents()
	assign_permanent_slots()

func disable_buttons() -> void:
	for slot in slots:
		if slot.get_child(0):
			var post = slot.get_child(0)
			var button = post.find_child("Button")
			button.disabled = true

func assign_permanent_slots() -> void:
	for panel in grid_container.get_children():
		if panel.get_child(0):
			continue
		else:
			available_permanent_slots.append(panel)

func connect_signals() -> void:
	TurnData.buy.connect(reparent_permanent)
	TurnData.delete.connect(remove_permanent)

func update_data() -> void:
	money_amount.text = "%.2f" % TurnData.money
	post_chance_value.text = str(TurnData.threshold_modifier)
	follower_amount.text = str(TurnData.follower_base)
	virality_chance_value.text = str(TurnData.viral_chance)
	sponsors_amount.text = str(TurnData.sponsors)
	sponsor_chance_value.text = str(TurnData.sponsor_chance)

func draw_permanents() -> void:
	for slot in slots:
		var permanent_chance: float = 0.1#randf()
		if permanent_chance <= TurnData.common_threshold:
			var permanent = initialize_random_permanent(3, "common")
			slot_management(slot, permanent)
		elif permanent_chance > TurnData.common_threshold and permanent_chance <= TurnData.normal_threshold:
			var permanent = initialize_random_permanent(6, "normal")
			slot_management(slot, permanent)
		elif permanent_chance > TurnData.normal_threshold and permanent_chance <= TurnData.uncommon_threshold:
			var permanent = initialize_random_permanent(7, "uncommon")
			slot_management(slot, permanent)
		elif permanent_chance > TurnData.uncommon_threshold and permanent_chance <= TurnData.rare_threshold:
			var permanent = initialize_random_permanent(5, "rare")
			slot_management(slot, permanent)
		else:
			var permanent = initialize_random_permanent(7, "legendary")
			slot_management(slot, permanent)

func slot_management(slot: PanelContainer, post: Node) -> void:
	slot.add_child(post)

func initialize_random_permanent(index_max: int, rarity: String) -> Node:
	var index: int = randi_range(0, index_max)
	var load_permanent
	match rarity:
		"common":
			load_permanent = load(common_permanents[index])
		"normal":
			load_permanent = load(normal_permanents[index])
		"uncommon":
			load_permanent = load(uncommon_permanents[index])
		"rare":
			load_permanent = load(rare_permanents[index])
		"legendary":
			load_permanent = load(legendary_permanents[index])
	return load_permanent.instantiate()

func fill_in_permanents() -> void:
	var index: int = 0
	var panels: Array = grid_container.get_children()
	for permanent in TurnData.permanents:
		if permanent == null:
			break
		else:
			num_permanents += 1
			var perm = load(permanent)
			panels[index].add_child(perm.instantiate())
			index += 1
	for panel in panels:
		if panel.get_child(0):
			var permanent = panel.get_child(0)
			permanent.change_button()

func reparent_permanent(parent_node: PanelContainer) -> void:
	hide_buttons = true
	var permanent = parent_node.get_child(0)
	update_data()
	var new_parent
	if available_permanent_slots.size() != 0:
		new_parent = available_permanent_slots.pop_front()
	if new_parent and parent_node:
		parent_node.remove_child(permanent)
		new_parent.add_child(permanent)

func remove_permanent(parent_node: PanelContainer) -> void:
	available_permanent_slots.insert(0, parent_node)

func _process(_delta) -> void:
	if num_permanents == 9:
		hide_buttons = true
	if hide_buttons:
		disable_buttons()
		hide_buttons = false

func proceed_to_next_day() -> void:
	get_tree().change_scene_to_file("res://Scenes/Screens/posting_screen.tscn")
