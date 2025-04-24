extends Control

@export var off_attributes_data: Array[Attribute]
@export var def_attributes_data: Array[Attribute]
@export var current_type: AttributeType

signal attributes_selected(cards: Array[Card])

@onready var attribute_data: Array[Attribute]
@onready var title_label = $Background/Title
@onready var attr_list = $Background/AttributesList
@onready var select_button = $Background/SelectButton
@onready var selected_attribute: Attribute

enum AttributeType { OFFENSIVE, DEFENSIVE }
var selected_cards = []
var deck_cards = []

func _ready():
		title_label.text = 'Offensive Attributes' if current_type == AttributeType.OFFENSIVE else 'Defensive Attributes'
		attribute_data = off_attributes_data if current_type == AttributeType.OFFENSIVE else def_attributes_data
		populate_attribute_list()
#
func populate_attribute_list():
	if attr_list.get_child_count() > 0:
		for attr in attr_list.get_children():
			attr.queue_free()
	attribute_data = off_attributes_data if current_type == AttributeType.OFFENSIVE else def_attributes_data
	for attribute in attribute_data:
		var button = Button.new()
		button.text = attribute.name
		button.pressed.connect(func(): select_cards(attribute))
		attr_list.add_child(button)
#
func select_cards(attribute):
	selected_attribute = attribute
	selected_cards = attribute.cards_data
	select_button.disabled = false

func _on_select_button_pressed():
	deck_cards.append_array(selected_cards)
	var next = current_type == AttributeType.OFFENSIVE
	current_type = AttributeType.DEFENSIVE if next else AttributeType.OFFENSIVE
	title_label.text = "Defensive Attributes" if AttributeType.DEFENSIVE else "Offensive Attributes"
	if current_type == AttributeType.DEFENSIVE:
		populate_attribute_list()
	else:
		emit_signal("attributes_selected", deck_cards)
