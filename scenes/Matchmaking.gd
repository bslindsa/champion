extends Control

@onready var status_label = $Panel/Label
@onready var cancel_button = $Panel/CancelButton
@onready var spinner = $Panel/TextureRect

# Simulated matchmaking timeout for now
const TIMEOUT := 5.0
var time_waited := 0.0

func _ready():
	# Start matchmaking logic
	start_matchmaking()

func start_matchmaking():
	status_label.text = "Searching for opponent..."
	# TODO: Replace this with actual Socket.io connection logic
	time_waited = 0

func _process(delta):
	spinner.rotation += delta * 4.0
	time_waited += delta
	if time_waited >= TIMEOUT:
		match_found()


func match_found():
	status_label.text = "Match found! Loading..."
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/GamePage.tscn")

func _on_cancel_button_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
