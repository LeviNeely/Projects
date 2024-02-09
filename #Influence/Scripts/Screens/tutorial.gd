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
const content: Array[String] = [
	"Welcome to #Influence! You are an influencer whose main goal is to gain as much money, followers, and sponsors as possible within a 30 day round.",
	"This is the resources dashboard and shows you the amount of money, followers, and sponsors you currently have.",
	"This is the post selection area. Here, random posts will be displayed that you can purchase to increase one or more of your resources. Each post has different types of rarity. These rarities unlock after a certain number of days. Additionally, each post has a chance to go viral. Viral posts are 30% cheaper and 50% more powerful in their effects. Read through a post's description to better learn what effects it has.",
	"The Redraw button allows you to redraw three new random posts. You have 2 free redraws per day, after that they begin to cost money. If you find a post you want to save between redraws or days, you can select the save button.",
	"This is the post space area. It contains five slots that make up your post order. You can choose up to 5 posts and once you have chosen one, you can delete it if you change your mind. Post order matters, so choose your ordering wisely!",
	"When you have selected your posts and are ready to proceed to the next day, click the Post! button to submit your posts and reap the rewards!",
	"After you have posted, you will have the opportunity to select permanent upgrades. These are powerful and their abilities are enacted at the start of each new day. You can purchase, save, and delete permanent upgrades on the permanent selection screen. Here, you can review what permanents you currently have.",
	"You are now all set to begin your journey as an influencer! If you have any questions, you can click on the help button in any of the screens to see this information and more. Best of luck in your endeavors!"
]

## Function called when the tutorial starts
func _ready() -> void:
	play_tutorial()

## Function that runs the tutorial
func play_tutorial() -> void:
	#Explaining the game overall
	tutorial = tutorial_base.instantiate()
	label = tutorial.find_child("Description")
	label.text = content[0]
	root.add_child(tutorial)
	#Await the button to be clicked that tells the tutorial to continue
	await GlobalMethods.proceed
	#Explaining the resources dashboard
	tutorial_screen(resources, content[1])
	await GlobalMethods.proceed
	#Explaining the post selection area
	tutorial_screen(post_selection_body, content[2])
	await GlobalMethods.proceed
	#Explaining the redraw button
	tutorial_screen(redraw, content[3])
	await GlobalMethods.proceed
	#Explaining the post space area
	tutorial_screen(post_space_body, content[4])
	await GlobalMethods.proceed
	#Explaining the Post! button
	tutorial_screen(post_, content[5])
	await GlobalMethods.proceed
	#Explaining permanent upgrades
	tutorial_screen(passives_body, content[6])
	await GlobalMethods.proceed
	#Ending the tutorial
	tutorial = tutorial_base.instantiate()
	label = tutorial.find_child("Description")
	label.text = content[7]
	root.add_child(tutorial)
	await GlobalMethods.proceed
	get_tree().change_scene_to_file("res://Scenes/Screens/posting_screen.tscn")

## Function that updates which part of the tutorial is playing
func tutorial_screen(object: Node, content: String) -> void:
	#Each tutorial step follows the same patter: highlight the area using the shader...
	object.material = shader
	#...then wait for a few seconds before...
	await get_tree().create_timer(2).timeout
	#...showing the tutorial screen...
	tutorial = tutorial_base.instantiate()
	label = tutorial.find_child("Description")
	#...displaying the correct text...
	label.text = content
	#...and adding it to the scene...
	root.add_child(tutorial)
	#...before waiting for the user to click continue...
	await GlobalMethods.proceed
	#...and making the material no longer highlighted.
	object.material = null
