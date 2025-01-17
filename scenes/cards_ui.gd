extends Control

@export var cards_scenes : Array[PackedScene]
@export var player : Entity
@onready var card_container: HBoxContainer = $MarginContainer/HBoxContainer

func _ready() -> void:
	BattleManager.picked_upgrade.connect(hide_upgrades)

func card_menu_setup() -> void:
	for i in card_container.get_children():
		i.queue_free()
	for i in 3:
		var card = cards_scenes.pick_random() 
		var card_instance = card.instantiate()
		card_container.add_child(card_instance)
	
	show()

func hide_upgrades(_i, _j) -> void:
	player.is_attacking = false
	hide()
