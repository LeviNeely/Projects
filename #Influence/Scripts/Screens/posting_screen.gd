extends Control

#Post selection area variables
@onready var post_selection: HBoxContainer = %PostSelection
@onready var first_slot: PanelContainer = post_selection.get_children()[1]
@onready var second_slot: PanelContainer = post_selection.get_children()[2]
@onready var third_slot: PanelContainer = post_selection.get_children()[3]
@onready var slots: Array[PanelContainer] = [first_slot, second_slot, third_slot]

#Post order area variables
@onready var post_order: HBoxContainer = %PostOrder
@onready var first_post: PanelContainer = post_order.get_children()[0]
@onready var second_post: PanelContainer = post_order.get_children()[1]
@onready var third_post: PanelContainer = post_order.get_children()[2]
@onready var fourth_post: PanelContainer = post_order.get_children()[3]
@onready var fifth_post: PanelContainer = post_order.get_children()[4]
@onready var available_posts: Array[PanelContainer] = [
	first_post, 
	second_post, 
	third_post, 
	fourth_post, 
	fifth_post
]

#Permanents area variables
@onready var permanent_1: PanelContainer = %Permanent1
@onready var permanent_3: PanelContainer = %Permanent3
@onready var permanent_2: PanelContainer = %Permanent2
@onready var permanent_4: PanelContainer = %Permanent4
@onready var permanent_5: PanelContainer = %Permanent5
@onready var permanent_6: PanelContainer = %Permanent6
@onready var permanent_7: PanelContainer = %Permanent7
@onready var permanent_8: PanelContainer = %Permanent8
@onready var permanent_9: PanelContainer = %Permanent9
@onready var permanents_grid: Array[PanelContainer] = [
	permanent_1,
	permanent_2,
	permanent_3,
	permanent_4,
	permanent_5,
	permanent_6,
	permanent_7,
	permanent_8,
	permanent_9
]

#Player data variables
@onready var money_amount: Label = %MoneyAmount
@onready var followers_amounts: Label = %FollowersAmounts
@onready var sponsors_amounts: Label = %SponsorsAmounts

#Button variables
@onready var redraw: Button = %Redraw

#Post names
const common_posts: Array[String] = [
	"res://Scenes/Posts/CommonPosts/common_meme.tscn",
	"res://Scenes/Posts/CommonPosts/dog_shelter.tscn",
	"res://Scenes/Posts/CommonPosts/finance_pal.tscn",
	"res://Scenes/Posts/CommonPosts/food_review.tscn",
	"res://Scenes/Posts/CommonPosts/independent.tscn",
	"res://Scenes/Posts/CommonPosts/lifestyle_post.tscn"
]
const normal_posts: Array[String] = [
	"res://Scenes/Posts/NormalPosts/diabetic_supplies.tscn",
	"res://Scenes/Posts/NormalPosts/finance_homie.tscn",
	"res://Scenes/Posts/NormalPosts/fit_check.tscn",
	"res://Scenes/Posts/NormalPosts/normal_meme.tscn",
	"res://Scenes/Posts/NormalPosts/restaurant_opening.tscn",
	"res://Scenes/Posts/NormalPosts/takes_money_to_make_money.tscn"
]
const uncommon_posts: Array[String] = [
	"res://Scenes/Posts/UncommonPosts/local_sponsored_post.tscn",
	"res://Scenes/Posts/UncommonPosts/make_it_on_your_own.tscn",
	"res://Scenes/Posts/UncommonPosts/self_made_post.tscn",
	"res://Scenes/Posts/UncommonPosts/support_kids_with_cancer.tscn",
	"res://Scenes/Posts/UncommonPosts/tech_review.tscn",
	"res://Scenes/Posts/UncommonPosts/travel_vlog.tscn",
	"res://Scenes/Posts/UncommonPosts/uncommon_meme.tscn"
]
const rare_posts: Array[String] = [
	"res://Scenes/Posts/RarePosts/corporate_sponsored_post.tscn",
	"res://Scenes/Posts/RarePosts/exotic_getaway.tscn",
	"res://Scenes/Posts/RarePosts/first_in_last_out.tscn",
	"res://Scenes/Posts/RarePosts/rare_meme.tscn",
	"res://Scenes/Posts/RarePosts/the_grind.tscn"
]
const legendary_posts: Array[String] = [
	"res://Scenes/Posts/LegendaryPosts/apology_video.tscn",
	"res://Scenes/Posts/LegendaryPosts/constantly_connected.tscn",
	"res://Scenes/Posts/LegendaryPosts/impeccable_image.tscn",
	"res://Scenes/Posts/LegendaryPosts/mlm_post.tscn",
	"res://Scenes/Posts/LegendaryPosts/self_care.tscn",
	"res://Scenes/Posts/LegendaryPosts/trend_tracker.tscn",
	"res://Scenes/Posts/LegendaryPosts/youthful_aesthetic.tscn"
]
const ally_posts: Array[String] = [
	"res://Scenes/Posts/CommonPosts/donate_aid_for_saharazad.tscn",
	"res://Scenes/Posts/NormalPosts/follow_influencers_on_the_ground_in_saharazad.tscn",
	"res://Scenes/Posts/UncommonPosts/contact_your_representatives_to_call_for_a_ceasefire.tscn",
	"res://Scenes/Posts/RarePosts/attend_a_protest_to_stop_the_genocide_in_saharazad.tscn",
	"res://Scenes/Posts/LegendaryPosts/boycott_all_companies_that_support_occupation_and_genocide.tscn"
]

#Random variables
var start_up: bool = true
const grow_factor: int = 2
const grow_percentage: float = 0.01
var viral_chance: float
var permanents: Array = []
var not_stored: bool = true

func _ready() -> void:
	randomize()
	connect_signals()
	reset_data()
	play_permanents()
	prepare_money()
	draw_posts()
	fill_in_permanents()
	update_data()
	update_date()

func create_permanents() -> void:
	for permanent in TurnData.permanents:
		if permanent != null:
			var perm = load(permanent)
			var instance = perm.instantiate()
			permanents.append(instance)

func play_permanents() -> void:
	create_permanents()
	for permanent in permanents:
		permanent.play()
	if TurnData.double_permanents:
		TurnData.double_permanents = false

func fill_in_permanents() -> void:
	var index: int = 0
	for permanent in permanents:
		permanents_grid[index].add_child(permanent)
		permanent.hide_cost_and_button()
		index += 1

func prepare_money() -> void:
	TurnData.start_money = TurnData.money

func reset_data() -> void:
	prepare_money()
	TurnData.num_free_redraws = 2
	TurnData.num_paid_redraws = 0
	TurnData.num_common_posts = 0
	TurnData.num_normal_posts = 0
	TurnData.num_uncommon_posts = 0
	TurnData.num_rare_posts = 0
	TurnData.num_legendary_posts = 0
	TurnData.num_viral_posts = 0
	TurnData.sponsor_multiplier = 1
	TurnData.player_hand = [null, null, null, null, null]

func update_date() -> void:
	%Day.text = "Day " + str(TurnData.date)

func connect_signals() -> void:
	TurnData.move.connect(reparent_post)
	TurnData.remove.connect(remove_post)

func check_if_redraw_is_valid() -> void:
	var cost: float = float(get_redraw_cost())
	if TurnData.money < cost:
		redraw.disabled = true

func clear_posts() -> void:
	for slot in slots:
		if not slot.get_children().is_empty():
			slot.get_children()[0].queue_free()

func draw_posts() -> void:
	update_redraw_button()
	check_if_redraw_is_valid()
	clear_posts()
	determine_posts()

func ininitialize_random_post(index_max: int, rarity: String) -> Node:
	var index: int = randi_range(0, index_max)
	var load_post
	match rarity:
		"common":
			load_post = load(common_posts[index])
		"normal":
			load_post = load(normal_posts[index])
		"uncommon":
			load_post = load(uncommon_posts[index])
		"rare":
			load_post = load(rare_posts[index])
		"legendary":
			load_post = load(legendary_posts[index])
	return load_post.instantiate()

func determine_posts() -> void:
	if TurnData.all_posts_viral:
		if not_stored:
			viral_chance = TurnData.viral_chance
			not_stored = false
		TurnData.viral_chance = 1.0
	for slot in slots:
		if TurnData.one_guaranteed_viral_post and not TurnData.all_posts_viral:
			viral_chance = TurnData.viral_chance
			TurnData.viral_chance = 1.0
		var post_chance: float = randf()
		var post
		if post_chance <= TurnData.common_threshold:
			var second_chance: float = randf()
			if TurnData.num_education_posts_read > 0 and second_chance < 0.25:
				post = load(ally_posts[TurnData.num_education_posts_read - 1])
				post = post.instantiate()
				slot_management(slot, post)
			else:
				post = ininitialize_random_post(5, "common")
				slot_management(slot, post)
		elif post_chance > TurnData.common_threshold and post_chance <= TurnData.normal_threshold:
			post = ininitialize_random_post(5, "normal")
			slot_management(slot, post)
		elif post_chance > TurnData.normal_threshold and post_chance <= TurnData.uncommon_threshold:
			post = ininitialize_random_post(6, "uncommon")
			slot_management(slot, post)
		elif post_chance > TurnData.uncommon_threshold and post_chance <= TurnData.rare_threshold:
			post = ininitialize_random_post(4, "rare")
			slot_management(slot, post)
		else:
			post = ininitialize_random_post(6, "legendary")
			slot_management(slot, post)
		if TurnData.one_guaranteed_viral_post and not TurnData.all_posts_viral:
			TurnData.viral_chance = viral_chance
			TurnData.one_guaranteed_viral_post = false
		if post.viral:
			TurnData.num_viral_posts += 1

func _process(_delta) -> void:
	update_buttons()

func update_buttons() -> void:
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

func slot_management(slot: PanelContainer, post: Node) -> void:
	slot.add_child(post)

func reparent_post(parent_node: PanelContainer) -> void:
	var post = parent_node.get_child(0)
	TurnData.money -= (snapped((TurnData.start_money * post.price_multiplier), 0.01))
	update_data()
	var new_parent
	var index: int = 0
	for parent in available_posts:
		if parent != null:
			new_parent = parent
			available_posts[index] = null
			break
		index += 1
	if new_parent and parent_node:
		parent_node.remove_child(post)
		new_parent.add_child(post)

func remove_post(parent_node: PanelContainer) -> void:
	var index: int = 0
	for parent in available_posts:
		if parent == null:
			available_posts[index] = parent_node
			break
		index += 1
	available_posts.append(parent_node)

func update_data() -> void:
	money_amount.text = "%.2f" % TurnData.money
	followers_amounts.text = str(TurnData.follower_base)
	sponsors_amounts.text = str(TurnData.sponsors)

func update_redraw_button() -> void:
	if TurnData.num_free_redraws == 0:
		var cost: float = float(get_redraw_cost())
		TurnData.money -= snapped(cost, 0.01)
		update_data()
	if start_up:
		start_up = false
		redraw.text = "Redraw (%d)" % TurnData.num_free_redraws
	else:
		if TurnData.num_free_redraws > 0:
			TurnData.num_free_redraws -= 1
			if TurnData.num_free_redraws == 0:
				redraw.text = "Redraw $" + get_redraw_cost()
			else:
				redraw.text = "Redraw (%d)" % TurnData.num_free_redraws
		else:
			TurnData.num_paid_redraws += 1
			redraw.text = "Redraw $" + get_redraw_cost()

func get_redraw_cost() -> String:
	var cost: float
	var money: float = TurnData.start_money
	var num_redraws: int = TurnData.num_paid_redraws
	cost = snapped((money * grow_percentage * pow(grow_factor, num_redraws)), 0.01)
	return "%.2f" % cost

func play() -> void:
	if TurnData.all_posts_viral:
		TurnData.viral_chance = viral_chance
		TurnData.all_posts_viral = false
	for post in TurnData.player_hand:
		if post != null:
			if post.viral:
				TurnData.num_viral_posts_posted += 1
			post.play()
	TurnData.date += 1
	TurnData.save_data()
	get_tree().change_scene_to_file("res://Scenes/Screens/follower_award_screen.tscn")

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
