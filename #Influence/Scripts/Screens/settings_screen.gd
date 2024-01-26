extends PanelContainer

@onready var music_volume: HSlider = %MusicVolume
@onready var background_volume: HSlider = %BackgroundVolume
@onready var sfx_volume: HSlider = %SFXVolume

func _ready() -> void:
	music_volume.value = db_to_linear(Settings.music_volume)
	background_volume.value = db_to_linear(Settings.background_volume)
	sfx_volume.value = db_to_linear(Settings.sfx_volume)

func _on_music_volume_value_changed(value: float) -> void:
	Settings.music_volume = linear_to_db(value)
	Settings.update_volume()

func _on_background_volume_value_changed(value):
	Settings.background_volume = linear_to_db(value)
	Settings.update_volume()

func _on_sfx_volume_value_changed(value):
	Settings.sfx_volume = linear_to_db(value)
	Settings.update_volume()

func _on_button_mouse_entered():
	ButtonHover.play()

func _on_button_pressed():
	ButtonClick.play()
	queue_free()
