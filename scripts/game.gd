extends Control

var letter_tile = preload("res://scenes/letter_tile.tscn")
var well_done = preload("res://scenes/well_done.tscn")
var answer: String
@onready var audioStreamPlayer: AudioStreamPlayer = $AudioStreamPlayer
var guess_finished: Callable
var play_finished: Callable
var well_done_finished: Callable

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	generate_answer()

func disable_buttons():
	#print("disable_buttons")
	$TextureButton.disabled = true
	var children = $HBoxContainer.get_children()
	for child in children:
		child.disable_button()

func enable_buttons():
	#print("enable_buttons")
	$TextureButton.disabled = false
	var children = $HBoxContainer.get_children()
	for child in children:
		child.enable_button()

func disconnect_finished():
	#print("disconnect_finished")
	if not guess_finished.is_null():
		if audioStreamPlayer.finished.is_connected(guess_finished):
			#print("disconnect guess_finished")
			audioStreamPlayer.finished.disconnect(guess_finished)
	if not play_finished.is_null():
		if audioStreamPlayer.finished.is_connected(play_finished):
			#print("disconnect play_finished")
			audioStreamPlayer.finished.disconnect(play_finished)

func guess(guessed_letter):
	#print("guess: " + guessed_letter)
	# disable guessing
	disable_buttons()
	var sound = load("res://sounds/"+guessed_letter+".wav")
	audioStreamPlayer.stream = sound
	guess_finished = func():
		#print("guess finished")
		disconnect_finished()
		if guessed_letter.to_lower() == answer.to_lower():
			# play fanfare sound
			sound = load("res://sounds/fanfare.ogg")
			audioStreamPlayer.stream = sound
			audioStreamPlayer.play(0.0)
			# play well done animation
			var well_done_instance = well_done.instantiate()
			add_child(well_done_instance)
			# start timer to generate next word
			well_done_finished = func ():
				#print("well_done finished")
				if $Timer.timeout.is_connected(well_done_finished):
						$Timer.timeout.disconnect(well_done_finished)
				remove_child(well_done_instance)
				generate_answer()
				enable_buttons()
			$Timer.timeout.connect(well_done_finished)
			$Timer.start()
		else:
			enable_buttons()
	audioStreamPlayer.finished.connect(guess_finished)
	audioStreamPlayer.play(0.0)

func generate_answer():
	#print("generate_answer")
	var answers = [
		"A",
		"B",
		"C",
		"D",
		"E",
		"F",
		"G",
		"H",
		"I",
		"J",
		"K",
		"L",
		"M",
		"N",
		"O",
		"P",
		"Q",
		"R",
		"S",
		"T",
		"U",
		"V",
		"W",
		"X",
		"Y",
		"Z",
	]
	answer = answers[randi() % answers.size()]
	#print(answer)
	var children = $HBoxContainer.get_children()
	for child in children:
		child.queue_free()
	var possible_answers: Array
	possible_answers.append(answer)
	answers.erase(answer)
	while possible_answers.size() < 5:
		answers.shuffle()
		possible_answers.append(answers[0])
		answers.erase(possible_answers[possible_answers.size()-1])
	possible_answers.shuffle()
	for option in possible_answers:
		var letter_tile_instance = letter_tile.instantiate()
		letter_tile_instance.letter = option
		letter_tile_instance.guess.connect(guess)
		letter_tile_instance.disable_guessing.connect(disable_buttons)
		letter_tile_instance.enable_guessing.connect(enable_buttons)
		$HBoxContainer.add_child(letter_tile_instance)
	#var sound = load("res://sounds/testing.ogg")
	var sound = load("res://sounds/"+answer+".wav")
	audioStreamPlayer.stream = sound
	audioStreamPlayer.play(0.0)

func _on_texture_button_pressed():
	disable_buttons()
	var sound = load("res://sounds/"+answer+".wav")
	audioStreamPlayer.stream = sound
	play_finished = func():
		#print("play finished")
		disconnect_finished()
		enable_buttons()
	audioStreamPlayer.finished.connect(play_finished)
	audioStreamPlayer.play(0.0)
