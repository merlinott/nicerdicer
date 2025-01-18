extends Control

@onready var ui_anim_component: UIAnimationComponent = $Node
@onready var dice_texture : TextureRect = $MarginContainer/VBoxContainer/TextureRect
@onready var price_label : Label = $PriceLabel

@export var dice_sprites : Array[Texture2D]
@export var upgrade_index : int = 0

var entity : Entity
var number : int = 0
var price : int = 0

func _ready() -> void:
	number = randi() % dice_sprites.size() + 1
	dice_texture.texture = dice_sprites[number-1]
	ui_anim_component.default_scale = Vector2(1,1)
	price = number * (upgrade_index)
	price_label.text = str(price)



func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		printt(entity.coins, price)
		if entity.coins >= price:
			entity.coins -= price
			BattleManager.picked_upgrade.emit(number, upgrade_index)
