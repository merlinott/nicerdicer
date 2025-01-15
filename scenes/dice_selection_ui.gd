extends Control
@onready var texture_rect_01: TextureRect = $MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/TextureRect
var dice_01_value := [0,0]
@onready var texture_rect_02: TextureRect = $MarginContainer/VBoxContainer/HBoxContainer/PanelContainer2/TextureRect
var dice_02_value := [0,0]
@onready var texture_rect_03: TextureRect = $MarginContainer/VBoxContainer/HBoxContainer/PanelContainer3/TextureRect
var dice_03_value := [0,0]

func _ready() -> void:
	texture_rect_01.gui_input.connect(get_dice.bind(0))
	texture_rect_02.gui_input.connect(get_dice.bind(1))
	texture_rect_03.gui_input.connect(get_dice.bind(2))

func set_dice_selection(i : int, dice_texture : Texture, data : Array):
	match i:
		0:
			dice_01_value = data
			texture_rect_01.texture = dice_texture
		1:
			dice_02_value = data
			texture_rect_02.texture = dice_texture
		2:
			dice_03_value = data
			texture_rect_03.texture = dice_texture

	
func get_dice(input, num : int):
	match num:
		0:
			BattleManager.select_dice(dice_01_value)
		1:
			BattleManager.select_dice(dice_01_value)
		2:
			BattleManager.select_dice(dice_01_value)
			
