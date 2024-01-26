extends Control

@onready var root: CanvasLayer = %CanvasLayer
@onready var texture_button: TextureButton = %TextureButton
@onready var texture_button_2: TextureButton = %TextureButton2
@onready var texture_button_3: TextureButton = %TextureButton3
@onready var texture_button_4: TextureButton = %TextureButton4
@onready var texture_button_5: TextureButton = %TextureButton5
@onready var texture_button_6: TextureButton = %TextureButton6
@onready var texture_button_7: TextureButton = %TextureButton7
@onready var texture_button_8: TextureButton = %TextureButton8
@onready var texture_button_9: TextureButton = %TextureButton9
@onready var texture_button_10: TextureButton = %TextureButton10
@onready var texture_button_11: TextureButton = %TextureButton11
@onready var texture_button_12: TextureButton = %TextureButton12
@onready var texture_button_13: TextureButton = %TextureButton13
@onready var texture_button_14: TextureButton = %TextureButton14
@onready var texture_button_15: TextureButton = %TextureButton15
@onready var texture_button_16: TextureButton = %TextureButton16
@onready var texture_button_17: TextureButton = %TextureButton17
@onready var texture_button_18: TextureButton = %TextureButton18
@onready var texture_button_19: TextureButton = %TextureButton19
@onready var texture_button_20: TextureButton = %TextureButton20
@onready var texture_button_21: TextureButton = %TextureButton21
@onready var texture_button_22: TextureButton = %TextureButton22
@onready var texture_button_23: TextureButton = %TextureButton23
@onready var texture_button_24: TextureButton = %TextureButton24
@onready var texture_button_25: TextureButton = %TextureButton25
@onready var badges: Array[TextureButton] = [
	texture_button,
	texture_button_2,
	texture_button_3,
	texture_button_4,
	texture_button_5,
	texture_button_6,
	texture_button_7,
	texture_button_8,
	texture_button_9,
	texture_button_10,
	texture_button_11,
	texture_button_12,
	texture_button_13,
	texture_button_14,
	texture_button_15,
	texture_button_16,
	texture_button_17,
	texture_button_18,
	texture_button_19,
	texture_button_20,
	texture_button_21,
	texture_button_22,
	texture_button_23,
	texture_button_24,
	texture_button_25
]

var booleans: Array[bool] = []

var panel: PanelContainer
var label: Label

func _ready() -> void:
	for badge in TurnData.earned_badges:
		var switch = TurnData.earned_badges[badge]
		if switch == true:
			switch = false
		else:
			switch = true
		booleans.append(switch)
	var index: int = 0
	for button in badges:
		button.disabled = booleans[index]
		connect_buttons(index, button)
		index += 1

func connect_buttons(index: int, button: TextureButton) -> void:
	button.connect("mouse_entered", Callable(self, "mouse_over").bind(index))
	button.connect("mouse_exited", mouse_off)

func mouse_over(index: int) -> void:
	ButtonHover.play()
	panel = PanelContainer.new()
	label = Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.custom_minimum_size = Vector2i(320, 0)
	match index:
		0:
			label.text = "Trillionaire: End a round with at least $1,000,000,000,000"
		1:
			label.text = "Crowdsourcing: End a round with at least 1,000 followers and $1,000,000"
		2:
			label.text = "Penniless, Friendless: End a round with $1,000 or less and 100 or fewer followers"
		3:
			label.text = "Popular: End a round with 5,000 or more followers"
		4:
			label.text = "Sell-Out: End a round with at least 100 sponsors and $1,000,000"
		5:
			label.text = "Capitalist Enabler: End a round with at least 500 sponsors"
		6:
			label.text = "Trend Setter: End a round with a viral chance of at least 2%"
		7:
			label.text = "Fumbled: End a round with a sponsor chance of at least 15%, but with 50 or fewer sponsors"
		8:
			label.text = "Capitalist Star: End a round with a sponsor chance of at least 20%"
		9:
			label.text = "Fortunate: End a round with a common chance of 30% or less"
		10:
			label.text = "Bribee: End a round with all 5 education posts read, but 10 or more sponsors"
		11:
			label.text = "Educated: End a round having read all 5 of the education posts"
		12:
			label.text = "Contradictory: End a round with at least 25 ally posts and 20 sponsors."
		13:
			label.text = "Conscientious Objector: End a round with at least 50 ally posts"
		14:
			label.text = "Lucky Ally: End a round with at least 25 viral posts and 20 ally posts"
		15:
			label.text = "Big Hit: End a round with at least 15 viral posts and $1,000,000"
		16:
			label.text = "Household Name: End a round with at least 15 viral posts and 1,000 followers"
		17:
			label.text = "Makes Sense: End a round with at least 25 viral posts and 2% viral chance"
		18:
			label.text = "Trending: End a round with at least 50 viral posts"
		19:
			label.text = "Doing Capitalism Wrong: End a round with $1,000 or less, 100 or fewer followers, and 10 or fewer sponsors"
		20:
			label.text = "Capitalism’s Bitch: End a round with at least $1,000,000,000, 5,000 followers, and 100 sponsors"
		21:
			label.text = "Refusing to Engage: End a round with viral, sponsor, and common post chance equal to starting values (1%, 10% and 50% respectively)"
		22:
			label.text = "Lucky Duck: End a round with at least 2% viral chance, 20% sponsor chance, and 30% or less common post chance"
		23:
			label.text = "The World is Watching: End a round with 5 educational posts and at least 25 ally posts and 5,000 followers"
		24:
			label.text = "Overachiever: End a round with rare post chance of 30% or less and at least 2% viral chance, 20% sponsor chance, $1,000,000,000, and 1500 followers"
	panel.add_child(label)
	panel.position = get_global_mouse_position()
	root.add_child(panel)

func mouse_off() -> void:
	root.remove_child(panel)

func _on_button_pressed():
	ButtonClick.play()
	get_tree().change_scene_to_file("res://Scenes/Screens/start_screen.tscn")

func _on_button_mouse_entered():
	ButtonHover.play()
