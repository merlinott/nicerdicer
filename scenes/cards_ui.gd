extends Control

@export var cards_scenes : Array[PackedScene]
@export var entity : Entity
@onready var card_container: HBoxContainer = $MarginContainer/HBoxContainer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	BattleManager.picked_upgrade.connect(hide_upgrades)

func card_menu_setup() -> void:
	for i in card_container.get_children():
		i.queue_free()
	for i in 3:
		var card = cards_scenes.pick_random() 
		var card_instance = card.instantiate()
		card_instance.entity = entity
		card_container.add_child(card_instance)
		if card_instance.price > entity.coins:
			card_instance.modulate = Color(1,1,1,0.5)
		else:
			card_instance.modulate = Color(1,1,1,1)

		
	show()
	animation_player.play("default")


func hide_upgrades(_i, _j) -> void:
	entity.is_attacking = false
	hide()


func _on_button_pressed() -> void:
	hide_upgrades(0,0)
