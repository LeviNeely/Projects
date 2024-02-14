extends Control

#The "root" of the scene where everything is drawn
@onready var root: CanvasLayer = %CanvasLayer

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
@onready var save_shader: ShaderMaterial = preload("res://Assets/Shaders/saved_post.tres")

## Function called on initialization
func _ready() -> void:
	randomize()
	connect_signals()
	update_data()
	determine_education_amount()
	draw_permanents()
	fill_in_permanents()
	assign_permanent_slots()
	update_date()

## Function to update what day it is in the game
func update_date() -> void:
	%Day.text = "Day " + str(TurnData.date - 1)

## Function that makes sure to not offer education posts if all have been seen
func determine_education_amount() -> void:
	if TurnData.num_education_posts_read == 5:
		education_offered = true

## Function that disables buttons of all slots
func disable_buttons() -> void:
	for slot in slots:
		if slot.get_child(0):
			var post = slot.get_child(0)
			var button = post.find_child("Button")
			button.disabled = true

## Function that assigns permanents to the various available slots
func assign_permanent_slots() -> void:
	for panel in grid_container.get_children():
		if panel.get_child(0):
			continue
		else:
			available_permanent_slots.append(panel)

## Function that connects signals to their respective methods
func connect_signals() -> void:
	TurnData.buy.connect(reparent_permanent)
	TurnData.delete.connect(remove_permanent)

## Function that updates all necessary player data
func update_data() -> void:
	money_amount.text = GlobalMethods.determine_money_amount(TurnData.money)
	post_chance_value.text = "%.2f" % (TurnData.threshold_modifier * 100) + "%"
	follower_amount.text = str(TurnData.follower_base)
	virality_chance_value.text = "%.2f" % (TurnData.viral_chance * 100) + "%"
	sponsors_amount.text = str(TurnData.sponsors)
	sponsor_chance_value.text = "%.2f" % (TurnData.sponsor_chance * 100) + "%"

## Function that returns a float based on what day it is, allowing for increasing rarity chances as time goes on
func random_float_based_on_day(date: int) -> float:
	if date <= 3:
		return randf_range(0.0, TurnData.common_threshold)
	elif date <= 6:
		return randf_range(0.0, TurnData.normal_threshold)
	elif date <= 9:
		return randf_range(0.0, TurnData.uncommon_threshold)
	elif date <= 12:
		return randf_range(0.0, TurnData.rare_threshold)
	else:
		return randf_range(0.0, 1.0)

## Function that determines what random permanents should be displayed
func draw_permanents() -> void:
	var index: int = 0
	for slot in slots:
		#First check to see if there are any saved permanents
		if TurnData.saved_permanents[index] != null:
			var permanent = load(TurnData.saved_permanents[index])
			permanent = permanent.instantiate()
			var check_box = permanent.find_child("CheckBox")
			check_box.button_pressed = true
			permanent.material = save_shader
			slot_management(slot, permanent)
		#Otherwise choose random permanents
		else:
			var permanent_chance: float = random_float_based_on_day(TurnData.date - 1)
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
		index += 1

## Function to add a permanent to a slot
func slot_management(slot: PanelContainer, post: Node) -> void:
	slot.add_child(post)

## Function that initializes a random post based on different rarities
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

## Function that fills in the permanents that the player already has purchased
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
			var vbox: VBoxContainer = permanent.find_child("Save")
			permanent.change_button()
			vbox.visible = false

## Function that reparents a permanent once it is purchased and continues to the next day
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

## Function that deletes a permanent
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

## Function called every frame of the game
func _process(_delta) -> void:
	if num_permanents == 9:
		disable_buttons()

## Function that activates buttons, allowing for purchase
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

## Function that changes the scene to the next round
func proceed_to_next_day() -> void:
	ButtonClick.play()
	if TurnData.date == 31:
		TurnData.finished_first_game = true
		TurnData.save_data()
		Music.play_end_theme()
		get_tree().change_scene_to_file("res://Scenes/Screens/end_screen.tscn")
	else:
		TurnData.save_data()
		get_tree().change_scene_to_file("res://Scenes/Screens/posting_screen.tscn")

#Event listeners
func _on_close_pressed():
	ButtonClick.play()
	TurnData.save_data()
	get_tree().quit()

func _on_home_pressed():
	ButtonClick.play()
	TurnData.save_data()
	get_tree().change_scene_to_file("res://Scenes/Screens/start_screen.tscn")

func _on_save_pressed():
	ButtonClick.play()
	TurnData.save_data()

func _notification(what) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		TurnData.save_data()

func _on_close_mouse_entered():
	ButtonHover.play()

func _on_home_mouse_entered():
	ButtonHover.play()

func _on_save_mouse_entered():
	ButtonHover.play()

func _on_continue_button_mouse_entered():
	ButtonHover.play()

func _on_help_pressed():
	ButtonClick.play()
	var help = load("res://Scenes/Screens/help_screen.tscn")
	help = help.instantiate()
	root.add_child(help)

func _on_help_mouse_entered():
	ButtonHover.play()

func _on_settings_mouse_entered():
	ButtonHover.play()

func _on_settings_pressed():
	ButtonClick.play()
	var settings = load("res://Scenes/Screens/settings_screen.tscn")
	settings = settings.instantiate()
	root.add_child(settings)
