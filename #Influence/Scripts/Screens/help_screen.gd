extends PanelContainer

@onready var root: Control = %CanvasLayer
@onready var texture_rect: TextureRect = %TextureRect
@onready var texture_rect_2: TextureRect = %TextureRect2
@onready var texture_rect_3: TextureRect = %TextureRect3
@onready var texture_rect_4: TextureRect = %TextureRect4
@onready var texture_rect_5: TextureRect = %TextureRect5
@onready var texture_rect_6: TextureRect = %TextureRect6
@onready var texture_rect_7: TextureRect = %TextureRect7
@onready var texture_rect_8: TextureRect = %TextureRect8
@onready var texture_rect_9: TextureRect = %TextureRect9
@onready var texture_rect_10: TextureRect = %TextureRect10
@onready var texture_rect_11: TextureRect = %TextureRect11
@onready var texture_rect_12: TextureRect = %TextureRect12
@onready var panel_container: PanelContainer = %PanelContainer
@onready var panel_container_2: PanelContainer = %PanelContainer2
@onready var panel_container_3: PanelContainer = %PanelContainer3
@onready var panel_container_4: PanelContainer = %PanelContainer4
@onready var panel_container_5: PanelContainer = %PanelContainer5
@onready var panel_container_6: PanelContainer = %PanelContainer6
@onready var help_icons: Array = [
	texture_rect,
	texture_rect_2,
	texture_rect_3,
	texture_rect_4,
	texture_rect_5,
	texture_rect_6,
	texture_rect_7,
	texture_rect_8,
	texture_rect_9,
	texture_rect_10,
	texture_rect_11,
	texture_rect_12,
	panel_container,
	panel_container_2,
	panel_container_3,
	panel_container_4,
	panel_container_5,
	panel_container_6
]

var text: Array[String] = [
	"Money: The current amount of money that you currently have.",
	"Followers: The number of followers that you currently have.",
	"Sponsors: The number of sponsors that you currently have.",
	"Rare Post Chance: The probability of a common post being drawn. The lower this value is, the more frequently rarer posts will be drawn.",
	"Virality Chance: The probability that posts become viral.",
	"Sponsor Chance: The probabiity that you will gain sponsors.",
	"Common: The most common type, appears 50% of the time.",
	"Normal: The next most common type, appears 19.2% of the time, unlocks on day 4.",
	"Uncommon: A more uncommon type, appears 15.4% of the time, unlocks on day 7.",
	"Rare: A rare type, appears 12.5% of the time, unlocks on day 10.",
	"Legendary: The most rare type, appears 3% of the time, unlocks on day 13.",
	"Viral: When a post goes viral, its abilities are 50% more powerful and costs 30% less. Occurs 1% of the time.",
	"You are an influencer trying to earn money, gain followers, and obtain sponsors. You have 30 days to acheive your dreams!",
	"In the posting screen you can draw posts, reroll posts drawn (you have a certain number of free redraws before having to pay), delete posts in your post order, save posts for a later day, and post your posts for the day (posting your posts for the day ends the day).",
	"Posts are the main way you can accomplish your goals of earning money, gaining followers, and obtaining sponsors. Each post has a different ability and costs, so read carefully!",
	"In the permanent screen you can purchase one permanent, save a permanent for a later day, and delete permanents you have already purchased. These permanent abilities can be powerful as their affects happen at the beginning of each day.",
	"Permanents are powerful permanent upgrades that activate at the beginning of every day. Each permanent has different abilities and costs, so read carefully!",
	"These are different achievements that you can earn if you complete a round (30 days) under certain conditiions. Unlocked after completing your first round."
]
var panel: PanelContainer
var info: Label

func _ready() -> void:
	var index: int = 0
	for icon in help_icons:
		connect_icons(index, icon)
		index += 1

func connect_icons(index: int, icon: Node) -> void:
	icon.connect("mouse_entered", Callable(self, "mouse_over").bind(index))
	icon.connect("mouse_exited", mouse_off)

func mouse_over(index: int) -> void:
	ButtonHover.play()
	panel = PanelContainer.new()
	info = Label.new()
	info.autowrap_mode = TextServer.AUTOWRAP_WORD
	info.custom_minimum_size = Vector2i(320, 0)
	info.text = text[index]
	panel.add_child(info)
	panel.position = get_local_mouse_position()
	root.add_child(panel)

func mouse_off() -> void:
	root.remove_child(panel)

func _on_button_pressed():
	ButtonClick.play()
	queue_free()

func _on_button_mouse_entered():
	ButtonHover.play()
