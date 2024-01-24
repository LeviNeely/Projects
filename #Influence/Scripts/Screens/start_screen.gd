extends Control

@onready var new_game: Button = %NewGame
@onready var load_game: Button = %LoadGame
@onready var badges: HBoxContainer = %Badges
@onready var badges_button: Button = %BadgesButton

func _ready() -> void:
	if not TurnData.finished_first_game:
		load_game.disabled = true
	if TurnData.finished_first_game:
		badges.visible = true

func _on_new_game_pressed() -> void:
	new_game.text = "New Round"
	load_game.text = "Continue Round"
	load_game.disabled = true
	new_game.disconnect("pressed", _on_new_game_pressed)
	new_game.connect("pressed", start_new_game)
	TurnData.completely_reset()
	TurnData.deep_reset()

func start_new_game() -> void:
	get_tree().change_scene_to_file("res://Scenes/Screens/posting_screen.tscn")

func _on_load_game_pressed() -> void:
	new_game.text = "New Round"
	load_game.text = "Continue Round"
	new_game.disconnect("pressed", _on_new_game_pressed)
	new_game.connect("pressed", start_new_round)
	load_game.disconnect("pressed", _on_load_game_pressed)
	load_game.connect("pressed", continue_round)
	if TurnData.date == 31:
		load_game.disabled = true

func start_new_round() -> void:
	TurnData.completely_reset()
	get_tree().change_scene_to_file("res://Scenes/Screens/posting_screen.tscn")

func continue_round() -> void:
	TurnData.load_data()
	get_tree().change_scene_to_file("res://Scenes/Screens/posting_screen.tscn")

func _on_options_pressed() -> void:
	pass # Eventually replace this with loading the options screen

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_badges_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Screens/badges_screen.tscn")
