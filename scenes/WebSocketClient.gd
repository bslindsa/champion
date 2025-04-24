extends Node

var socket := WebSocketPeer.new()
var connected = false

signal lobby_created(lobby_id)
signal game_started(lobby_id)
signal error_received(message)
signal connected_to_server
signal match_ready(lobby_id, player_index)

func _process(_delta):
	if connected:
		socket.poll()
		while socket.get_available_packet_count() > 0:
			var packet = socket.get_packet().get_string_from_utf8()
			var data = JSON.parse_string(packet)
			_handle_message(data)

func connect_to_server():
	var err = socket.connect_to_url("ws://localhost:8080")
	if err == OK:
		connected = true
	emit_signal("connected_to_server")

func _handle_message(data):
	match data["type"]:
		"lobby_created":
			emit_signal("lobby_created", data["lobbyId"])
		"start_game":
			emit_signal("game_started", data["lobbyId"])
		"error":
			emit_signal("error_received", data["message"])
		"message":
			print("Message from opponent:", data["content"])

func create_lobby():
	var msg = { "type": "create_lobby" }
	socket.send_text(JSON.stringify(msg))

func join_lobby(lobby_id: String):
	var msg = { "type": "join_lobby", "lobbyId": lobby_id }
	socket.send_text(JSON.stringify(msg))

func send_game_message(content: String, lobby_id: String):
	var msg = { "type": "message", "content": content, "lobbyId": lobby_id }
	socket.send_text(JSON.stringify(msg))

func _on_data_received():
	var msg = socket.get_packet().get_string_from_utf8()
	var data = JSON.parse_string(msg)
	if data:
		match data.type:
			"lobby_created":
				emit_signal("lobby_created", data.lobby_id)
			"lobby_joined":
				emit_signal("joined_lobby", data.lobby_id)
			"match_ready":
				# Expect data like: { type: "match_ready", lobby_id: "ABC123", player_index: 0 }
				emit_signal("match_ready", data.lobby_id, data.player_index)
