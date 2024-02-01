extends AudioStreamPlayer

const menu_theme: AudioStreamMP3 = preload("res://Assets/Audio/Music/MenuTheme.mp3")
const game_theme: AudioStreamMP3 = preload("res://Assets/Audio/Music/GameTheme.mp3")

func play_menu_theme() -> void:
	if self.playing:
		self.stop()
	self.stream = menu_theme
	self.play()

func play_game_theme() -> void:
	if self.playing:
		self.stop()
	self.stream = game_theme
	self.play()

func play_end_theme() -> void:
	pass
