extends Control

@export var card_data: Card  # Assign different card data for each instance

@onready var name_label = $NameLabel
@onready var effect_label = $EffectLabel
@onready var powerup_label = $PowerUpLabel
@onready var type_label = $TypeLabel
@onready var card_texture = $CardBackground  # Background texture
@onready var card_image = $CardArt  # New TextureRect for the card image

func _ready():
	if card_data:
		name_label.text = card_data.name
		type_label.text = card_data.type
		effect_label.text = card_data.effect
		powerup_label.text = card_data.power_up
		card_image.texture = card_data.texture  # Assign unique card image
