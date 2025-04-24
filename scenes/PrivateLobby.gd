extends Control

@export var lobby_id: String

@onready var title = $Panel/VBoxContainer/Title
@onready var message = $Panel/VBoxContainer/Message
@onready var id_display = $Panel/LobbyID

func _ready():
	title.text = "Host Champion's Arena"
	message.text = "Waiting for Challenger..."
	id_display.text = "Lobby ID: 12345"
	
