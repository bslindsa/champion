extends Control

@export var matchmaking = preload("res://scenes/Matchmaking.tscn").instantiate()

@onready var websocket = $WebsocketClient
@onready var line_edit_lobby_id = $"Panel/VBoxContainer/HBoxContainer/ArenaId"
@onready var matchmacking_placeholder = $MatchmakingPlaceholder

func _ready():
	websocket.connect("lobby_created", Callable(self, "_on_lobby_created"))
	websocket.connect("game_started", Callable(self, "_on_game_started"))
	websocket.connect("error_received", Callable(self, "_on_error_received"))
	websocket.connect("match_ready", Callable(self, "on_match_ready"))

func _on_random_match_pressed():
	websocket.connect_to_server()
	websocket.connect("connected_to_server", Callable(self, "_create_lobby_after_connection"))

func _on_create_arena_pressed():
	websocket.connect_to_server()
	websocket.connect("connected_to_server", Callable(self, "_create_lobby_after_connection"))

func _on_join_arena_pressed():
	var lobby_id = line_edit_lobby_id.text.strip_edges()
	if lobby_id != "":
		websocket.connect_to_server()
		websocket.join_lobby(lobby_id)

func _on_close_pressed():
	$'.'.hide()

# Signals from websocket
func _on_lobby_created(lobby_id):
	print("Lobby created with ID:", lobby_id)
	# Show lobby ID on screen for sharing
	# Optionally copy to clipboard or wait for 2nd player

func _on_game_started(lobby_id):
	print("Game starting in lobby:", lobby_id)
	# Transition to game scene

func _on_error_received(message):
	print("Matchmaking error:", message)
	# Show error popup or message label

func _create_lobby_after_connection():
	matchmacking_placeholder.add_child(matchmaking)
	websocket.create_lobby()

func _on_match_ready(lobby_id, player_index):
	print("Match ready! Lobby:", lobby_id, "You are player:", player_index)
	get_tree().change_scene_to_file("res://scenes/GamePage.tscn")
	Global.lobby_id = lobby_id
	Global.player_index = player_index
