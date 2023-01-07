extends TextureButton

@export var letter: String = "A"
@onready var audioStreamPlayer: AudioStreamPlayer = $AudioStreamPlayer
signal disable_guessing
signal enable_guessing
signal guess(letter: String)

var play_finished: Callable

func disable_button():
	#print("disable_button")
	disabled = true

func disable_buttons():
	#print("disable_buttons")
	disable_guessing.emit()

func enable_button():
	#print("enable_button")
	disabled = false

func enable_buttons():
	#print("enable_buttons")
	enable_guessing.emit()

func disconnect_finished():
	#print("disconnect_finished")
	if audioStreamPlayer.finished.is_connected(play_finished):
		#print("disconnect play_finished")
		audioStreamPlayer.finished.disconnect(play_finished)

func _ready():
	$Label.text = letter

func _on_tile_pressed():
	guess.emit(letter)
