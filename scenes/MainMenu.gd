extends Control

@export var matchmaking_dialog = preload("res://scenes/MatchmakingDialog.tscn")

func _on_challenge_pressed() -> void:
	$'.'.add_child(matchmaking_dialog.instantiate())

func _on_practice_pressed() -> void:
	# Load the single player game scene
	get_tree().change_scene_to_file("res://scenes/GamePage.tscn")
	
func _on_options_pressed() -> void:
	# Open the options/settings menu
	get_tree().change_scene_to_file("res://scenes/OptionsMenu.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
