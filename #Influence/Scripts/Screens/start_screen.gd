extends Control

#Variables that reference various buttons on the start screen
@onready var root: CanvasLayer = $CanvasLayer
@onready var new_game: Button = %NewGame
@onready var load_game: Button = %LoadGame
@onready var badges: HBoxContainer = %Badges
@onready var badges_button: Button = %BadgesButton

## Function called at initialization
func _ready() -> void:
	if not TurnData.finished_first_game:
		load_game.disabled = true
	if TurnData.finished_first_game:
		badges.visible = true

## Function called when a new journey is started
func _on_new_game_pressed() -> void:
	ButtonClick.play()
	new_game.text = "New Round"
	load_game.text = "Continue Round"
	load_game.disabled = true
	new_game.disconnect("pressed", _on_new_game_pressed)
	new_game.connect("pressed", start_new_game)
	TurnData.completely_reset()
	TurnData.deep_reset()

## Function called when a new round is started
func start_new_game() -> void:
	ButtonClick.play()
	Music.play_game_theme()
	#Make sure to play the tutorial if it hasn't been played yet
	if TurnData.date == 1 and not TurnData.finished_first_game:
		get_tree().change_scene_to_file("res://Scenes/Screens/tutorial.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/Screens/posting_screen.tscn")

## Function called when the player is continuing a journey
func _on_load_game_pressed() -> void:
	ButtonClick.play()
	new_game.text = "New Round"
	load_game.text = "Continue Round"
	new_game.disconnect("pressed", _on_new_game_pressed)
	new_game.connect("pressed", start_new_round)
	load_game.disconnect("pressed", _on_load_game_pressed)
	load_game.connect("pressed", continue_round)
	#If the player has finished a game, we don't want that game to continue past when it was supposed to
	if TurnData.date == 31:
		load_game.disabled = true

## Function called when a brand new round is started
func start_new_round() -> void:
	ButtonClick.play()
	TurnData.completely_reset()
	Music.play_game_theme()
	get_tree().change_scene_to_file("res://Scenes/Screens/posting_screen.tscn")

## Function called when the player continues a round
func continue_round() -> void:
	ButtonClick.play()
	TurnData.load_data()
	Music.play_game_theme()
	get_tree().change_scene_to_file("res://Scenes/Screens/posting_screen.tscn")

## Function called when the options/settings button is selected
func _on_options_pressed() -> void:
	ButtonClick.play()
	var settings = load("res://Scenes/Screens/settings_screen.tscn")
	settings = settings.instantiate()
	root.add_child(settings)

## Function called when the quit button is selected
func _on_quit_pressed() -> void:
	ButtonClick.play()
	get_tree().quit()

## Function called when the badges button is selected
func _on_badges_button_pressed():
	ButtonClick.play()
	get_tree().change_scene_to_file("res://Scenes/Screens/badges_screen.tscn")

#Event listeners for hovering over buttons
func _on_new_game_mouse_entered():
	if not new_game.disabled:
		ButtonHover.play()

func _on_load_game_mouse_entered():
	if not load_game.disabled:
		ButtonHover.play()

func _on_options_mouse_entered():
	ButtonHover.play()

func _on_quit_mouse_entered():
	ButtonHover.play()

func _on_badges_button_mouse_entered():
	if not badges_button.disabled:
		ButtonHover.play()
