extends Node

var socket := WebSocketPeer.new()
var connected = false

signal lobby_created(lobby_id)
signal game_started(lobby_id)
signal error_received(message)

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
