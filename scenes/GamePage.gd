extends Control

@export var card_ui_scene = preload("res://scenes/CardUI.tscn")  # Assign `CardUI.tscn`
@export var attribute_dialog_scene = preload("res://scenes/AttributesDialog.tscn").instantiate()
@export var card_resources: Array[Card]  # Assign different `.tres` files
@export var MAX_HAND_SIZE: int
@export var base_deck: Array[Card]

@onready var game_page = $"."
@onready var hand_container = $ChampionField/HandContainer
@onready var discard_pile = $ChampionField/Discard
@onready var play_hand_button = $CenterField/VBoxContainer/PlayHandButton
@onready var discard_button = $CenterField/VBoxContainer/DiscardButton
@onready var deck = $ChampionField/Deck
@onready var deck_count = $ChampionField/Deck/DeckCount

var hand = []  # Stores drawn cards
var discard_pile_tracker = []
var selected_cards = []  # Tracks the selected card in hand

func _ready():
	$'.'.add_child(attribute_dialog_scene)
	attribute_dialog_scene.connect('attributes_selected', Callable(self, 'add_cards_to_deck'))
	deck.modulate.a = 0.0

func add_cards_to_deck(cards_data):
	attribute_dialog_scene.queue_free()
	cards_data.append_array(base_deck)
	if deck.card_resources.is_empty():
		deck.modulate.a = 1.0
	for card_data in cards_data:
		deck.card_resources.append(card_data)  # Add to deck logic
		print(str(card_data.name) + ' added to deck')
	shuffle_deck()
	draw_cards()
	
func shuffle_deck():
	deck.card_resources.shuffle()
	print("Deck shuffled!")

func draw_cards():
	if deck.card_resources.is_empty():
		if discard_pile.get_child_count() == 0:
			print('There are no more cards to draw')
			return
		else:
			shuffle_discard_into_deck()
			
	for i in range(MAX_HAND_SIZE - hand.size()):
		var drawn_card = deck.card_resources.pop_at(0)
		if deck.card_resources.is_empty():
			deck.modulate.a = 0.0
	
		var card_instance = card_ui_scene.instantiate()
		card_instance.card_data = drawn_card
		print(card_instance)
		print(drawn_card)
		hand_container.add_child(card_instance)
		hand.append(card_instance)
		print("Drew a " + str(card_instance.card_data.name))

		card_instance.connect("gui_input", func(event):
			if event is InputEventMouseButton and event.pressed:
				select_card(card_instance)
	)
	deck_count.text = str(deck.card_resources.size())

func select_card(card_instance):
	if card_instance.selected:
		selected_cards.erase(card_instance)
		card_instance.selected = false
		if (selected_cards.is_empty() || !cards_are_multi_and_same()) && selected_cards.size() != 1:
			play_hand_button.disabled = true
		else:
			play_hand_button.disabled = false
	else:
		selected_cards.append(card_instance)
		card_instance.selected = true
		if selected_cards.size() == 1:
			play_hand_button.disabled = false
		else:
			play_hand_button.disabled = !cards_are_multi_and_same()
	
	discard_button.disabled = selected_cards.is_empty()

func cards_are_multi_and_same():
	if selected_cards.size() > 0:
		for card in selected_cards:
			if not card.card_data.multi || selected_cards[0].card_data.name != card.card_data.name:
				return false
#	Exclude Energy cards. They are only multi use if there are exactly 3 used.
	
	return true

func selected_3_energies():
	if selected_cards.size() == 3:
		for card in selected_cards:
			if card.card_data.name != "Energy":
				return false
		return true
	return false

func clear_selected_cards():
	for card in selected_cards:
		card.selected = false
	selected_cards = []

func _on_play_button_pressed():
#	Logic for card effects go here

	hand_to_discard_pile()

func _on_discard_button_pressed():
	hand_to_discard_pile()
#	Pass turn to other player

func shuffle_discard_into_deck():
	print('Reshuffle discard pile to deck')
	for card_data in discard_pile_tracker:
		deck.card_resources.append(card_data)
	for card in discard_pile.get_children():
		discard_pile.remove_child(card)
	discard_pile_tracker.clear()
	deck.modulate.a = 1.0
	deck.card_resources.shuffle()
	print(deck.card_resources.size())
	print(deck.card_resources)
	
func update_hand_array():
	hand.clear()
	for child in hand_container.get_children():
		hand.append(child)

func hand_to_discard_pile():
	for card in selected_cards:
		print("Played: ", card.card_data.name)
		card.selected = false
		hand.erase(card)  # Remove from hand
		hand_container.remove_child(card)  # Remove from UI
		discard_pile.add_child(card)  # Move to discard pile
		discard_pile_tracker.append(card.card_data)
		
	if selected_cards.size() >= deck.card_resources.size():
		shuffle_discard_into_deck()
		
	selected_cards = []
	play_hand_button.disabled = true  # Disable button again
	discard_button.disabled = true
	
	draw_cards()
