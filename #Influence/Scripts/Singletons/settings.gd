extends Node

#Volume values
var background_volume: float = -10.0
var sfx_volume: float = -2.0
var music_volume: float = -4.0

## Function called when the game starts
func _ready() -> void:
	update_volume()

## Function called to update the volume values
func update_volume() -> void:
	BackgroundAudio.volume_db = background_volume
	ButtonClick.volume_db = sfx_volume
	ButtonHover.volume_db = sfx_volume
	ButtonDelete.volume_db = sfx_volume
	Music.volume_db = music_volume
