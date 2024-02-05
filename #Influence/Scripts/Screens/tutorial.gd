extends Control

#Shader
@onready var shader: ShaderMaterial = preload("res://Assets/Shaders/new_shader_material.tres")

#Portions of the screen that need to be accessed
@onready var root: CanvasLayer = %CanvasLayer
@onready var tutorial_base: PackedScene = preload("res://Scenes/Templates/tutorial_base.tscn")
@onready var resources: PanelContainer = %ResourcesBody
@onready var post_selection_body: PanelContainer = %PostSelectionBody
@onready var redraw: Button = %Redraw
@onready var post_: Button = %"Post!"
@onready var post_space_body: PanelContainer = %PostSpaceBody
@onready var passives_body: PanelContainer = %PassivesBody

#Tutorial variables
var tutorial
var label

func _ready() -> void:
	play_tutorial()

func play_tutorial() -> void:
	tutorial = tutorial_base.instantiate()
	label = tutorial.find_child("Description")
	label.text = "Welcome to #Influence! You are an influencer whose main goal is to gain as much money, followers, and sponsors as possible within a 30 day round."
	root.add_child(tutorial)
	await GlobalMethods.proceed
	resources.material = shader
	await get_tree().create_timer(2).timeout
	tutorial = tutorial_base.instantiate()
	label = tutorial.find_child("Description")
	label.text = "This is the resources dashboard and shows you the amount of money, followers, and sponsors you currently have."
	root.add_child(tutorial)
	await GlobalMethods.proceed
	resources.material = null
	post_selection_body.material = shader
	await get_tree().create_timer(2).timeout
	tutorial = tutorial_base.instantiate()
	label = tutorial.find_child("Description")
	label.text = "This is the post selection area. Here, random posts will be displayed that you can purchase to increase one or more of your resources. Each post has different types of rarity. These rarities unlock after a certain number of days. Additionally, each post has a chance to go viral. Viral posts are 30% cheaper and 50% more powerful in their effects. Read through a post's description to better learn what effects it has."
	root.add_child(tutorial)
	await GlobalMethods.proceed
	post_selection_body.material = null
	redraw.material = shader
	await get_tree().create_timer(2).timeout
	tutorial = tutorial_base.instantiate()
	label = tutorial.find_child("Description")
	label.text = "The Redraw button allows you to redraw three new random posts. You have 2 free redraws per day, after that they begin to cost money. If you find a post you want to save between redraws or days, you can select the save button."
	root.add_child(tutorial)
	await GlobalMethods.proceed
	redraw.material = null
	post_space_body.material = shader
	await get_tree().create_timer(2).timeout
	tutorial = tutorial_base.instantiate()
	label = tutorial.find_child("Description")
	label.text = "This is the post space area. It contains five slots that make up your post order. You can choose up to 5 posts and once you have chosen one, you can delete it if you change your mind. Post order matters, so choose your ordering wisely!"
	root.add_child(tutorial)
	await GlobalMethods.proceed
	post_space_body.material = null
	post_.material = shader
	await get_tree().create_timer(2).timeout
	tutorial = tutorial_base.instantiate()
	label = tutorial.find_child("Description")
	label.text = "When you have selected your posts and are ready to proceed to the next day, click the Post! button to submit your posts and reap the rewards!"
	root.add_child(tutorial)
	await GlobalMethods.proceed
	post_.material = null
	passives_body.material = shader
	await get_tree().create_timer(2).timeout
	tutorial = tutorial_base.instantiate()
	label = tutorial.find_child("Description")
	label.text = "After you have posted, you will have the opportunity to select permanent upgrades. These are powerful and their abilities are enacted at the start of each new day. You can purchase, save, and delete permanent upgrades on the permanent selection screen. Here, you can review what permanents you currently have."
	root.add_child(tutorial)
	await GlobalMethods.proceed
	passives_body.material = null
	tutorial = tutorial_base.instantiate()
	label = tutorial.find_child("Description")
	label.text = "You are now all set to begin your journey as an influencer! If you have any questions, you can click on the help button in any of the screens to see this information and more. Best of luck in your endeavors!"
	root.add_child(tutorial)
	await GlobalMethods.proceed
	get_tree().change_scene_to_file("res://Scenes/Screens/posting_screen.tscn")
