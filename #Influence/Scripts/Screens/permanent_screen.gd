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
@onready var passives: Array[PanelContainer] = [
	passive_1,
	passive_2,
	passive_3,
	passive_4,
	passive_5,
	passive_6,
	passive_7,
	passive_8,
	passive_9
]

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
const normal_permanents: Array[String] = [
	"res://Scenes/Permanents/NormalPermanents/better_editing_software.tscn",
	"res://Scenes/Permanents/NormalPermanents/better_trending_page.tscn",
	"res://Scenes/Permanents/NormalPermanents/daily_live_streaming.tscn",
	"res://Scenes/Permanents/NormalPermanents/marketing_advice.tscn"
]
const uncommon_permanents: Array[String] = [
	"res://Scenes/Permanents/UncommonPermanents/best_editing_software.tscn",
	"res://Scenes/Permanents/UncommonPermanents/best_trending_page.tscn",
	"res://Scenes/Permanents/UncommonPermanents/brand_manager.tscn",
	"res://Scenes/Permanents/UncommonPermanents/hey_siblings.tscn"
]
const rare_permanents: Array[String] = [
	"res://Scenes/Permanents/RarePermanents/endorsement_deal.tscn",
	"res://Scenes/Permanents/RarePermanents/major_colab.tscn",
	"res://Scenes/Permanents/RarePermanents/post_engagement.tscn",
	"res://Scenes/Permanents/RarePermanents/trend_setter.tscn"
]
const legendary_permanents: Array[String] = [
	"res://Scenes/Permanents/LegendaryPermanents/engagement.tscn",
	"res://Scenes/Permanents/LegendaryPermanents/fitness_guru.tscn",
	"res://Scenes/Permanents/LegendaryPermanents/grwm.tscn",
	"res://Scenes/Permanents/LegendaryPermanents/perfect_image.tscn",
	"res://Scenes/Permanents/LegendaryPermanents/promotional_master.tscn"
]
const education_permanent: String = "res://Scenes/Permanents/EducationPermanent/education_permanent.tscn"

#Random variables
var available_permanent_slots: Array[PanelContainer] = []
var num_permanents: int = 0
var hide_buttons: bool = false
var education_offered: bool = false

func _ready() -> void:
	randomize()
	connect_signals()
	update_data()
	determine_education_amount()
	draw_permanents()
	fill_in_permanents()
	assign_permanent_slots()

func determine_education_amount() -> void:
	if TurnData.num_education_posts_read == 5:
		education_offered = true

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
	post_chance_value.text = "%.2f" % (TurnData.threshold_modifier * 100) + "%"
	follower_amount.text = str(TurnData.follower_base)
	virality_chance_value.text = "%.2f" % (TurnData.viral_chance * 100) + "%"
	sponsors_amount.text = str(TurnData.sponsors)
	sponsor_chance_value.text = "%.2f" % (TurnData.sponsor_chance * 100) + "%"

func draw_permanents() -> void:
	for slot in slots:
		var permanent_chance: float = randf()
		var permanent
		if permanent_chance <= TurnData.common_threshold:
			if education_offered:
				permanent = initialize_random_permanent(3, "common")
				slot_management(slot, permanent)
			else:
				education_offered = true
				permanent = load(education_permanent)
				permanent = permanent.instantiate()
				slot_management(slot, permanent)
		elif permanent_chance > TurnData.common_threshold and permanent_chance <= TurnData.normal_threshold:
			permanent = initialize_random_permanent(3, "normal")
			slot_management(slot, permanent)
		elif permanent_chance > TurnData.normal_threshold and permanent_chance <= TurnData.uncommon_threshold:
			permanent = initialize_random_permanent(3, "uncommon")
			slot_management(slot, permanent)
		elif permanent_chance > TurnData.uncommon_threshold and permanent_chance <= TurnData.rare_threshold:
			permanent = initialize_random_permanent(3, "rare")
			slot_management(slot, permanent)
		else:
			permanent = initialize_random_permanent(4, "legendary")
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
			continue
		else:
			num_permanents += 1
			var perm_file = load(permanent)
			var perm = perm_file.instantiate()
			perm.index = index
			panels[index].add_child(perm)
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
	proceed_to_next_day()

func remove_permanent(parent_node: PanelContainer) -> void:
	if num_permanents == 9:
		activate_buttons()
	var index: int = 0
	for panel in passives:
		if panel == parent_node:
			TurnData.permanents[index] = null
			break
		else:
			index += 1
	available_permanent_slots.insert(0, parent_node)
	num_permanents -= 1

func _process(_delta) -> void:
	if num_permanents == 9:
		disable_buttons()

func activate_buttons() -> void:
	for slot in slots:
		if slot.get_child(0):
			var post = slot.get_child(0)
			var button = post.find_child("Button")
			var cost = post.find_child("Cost")
			var price = float(cost.text.replace("$", ""))
			if price > TurnData.money:
				button.disabled = true
			else:
				button.disabled = false

func proceed_to_next_day() -> void:
	if TurnData.date == 31:
		TurnData.finished_first_game = true
		TurnData.save_data()
		get_tree().change_scene_to_file("res://Scenes/Screens/end_screen.tscn")
	else:
		TurnData.save_data()
		get_tree().change_scene_to_file("res://Scenes/Screens/posting_screen.tscn")

func _on_close_pressed():
	TurnData.save_data()
	get_tree().quit()

func _on_home_pressed():
	TurnData.save_data()
	get_tree().change_scene_to_file("res://Scenes/Screens/start_screen.tscn")

func _on_save_pressed():
	TurnData.save_data()

func _notification(what) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		TurnData.save_data()
