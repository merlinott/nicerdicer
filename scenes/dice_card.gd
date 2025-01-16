extends TextureRect

@export var dice_sprites : Array[Texture2D]
@onready var dice_texture : TextureRect = $MarginContainer/VBoxContainer/TextureRect

var number : int = 0
@export var upgrade_index : int = 0

func _ready() -> void:
	number = randi() % dice_sprites.size() + 1
	dice_texture.texture = dice_sprites[number-1]


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		BattleManager.picked_upgrade.emit(number, upgrade_index)
