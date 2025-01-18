extends Control

@export var entity : Entity

@onready var texture_rect_01: TextureRect = $MarginContainer/VBoxContainer/HBoxContainer/PanelContainer/TextureRect
var dice_01_value := [0,0]
@onready var texture_rect_02: TextureRect = $MarginContainer/VBoxContainer/HBoxContainer/PanelContainer2/TextureRect
var dice_02_value := [0,0]
@onready var texture_rect_03: TextureRect = $MarginContainer/VBoxContainer/HBoxContainer/PanelContainer3/TextureRect
var dice_03_value := [0,0]

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var first_dice_price : int = 0
var second_dice_price : int = 0
@onready var price_label_01: Label = $MarginContainer/VBoxContainer/Price/price_label_01
@onready var price_label_02: Label = $MarginContainer/VBoxContainer/Price/price_label_02
@onready var sfx: AudioStreamPlayer = $SFX


func _ready() -> void:
	texture_rect_01.gui_input.connect(get_dice.bind(0))
	texture_rect_02.gui_input.connect(get_dice.bind(1))
	texture_rect_03.gui_input.connect(get_dice.bind(2))

func set_dice_selection(i : int, dice_texture : Texture, data : Array):
	animation_player.play("default")
	
	match i:
		0:
			dice_01_value = data
			texture_rect_01.texture = dice_texture
			first_dice_price = data[0] * (data[1] + 1)
			if first_dice_price > entity.coins:
				texture_rect_01.modulate = Color(1,1,1,0.5)
			else:
				texture_rect_01.modulate = Color(1,1,1,1)
			price_label_01.text = str(first_dice_price)
		1:
			dice_02_value = data
			texture_rect_02.texture = dice_texture
		2:
			dice_03_value = data
			texture_rect_03.texture = dice_texture
			second_dice_price = data[0] * (data[1] + 1)
			if second_dice_price > entity.coins:
				texture_rect_03.modulate = Color(1,1,1,0.5)
			else:
				texture_rect_03.modulate = Color(1,1,1,1)
				
			price_label_02.text = str(second_dice_price)

	
func get_dice(input, num : int):
	if input is InputEventMouseButton and input.pressed and input.button_index == MOUSE_BUTTON_LEFT:
		match num:
			0:
				if entity.coins < first_dice_price:
					return
				entity.coins -= first_dice_price
				BattleManager.select_dice(dice_01_value)
			1:
				BattleManager.select_dice(dice_02_value)
			2:
				if entity.coins < second_dice_price:
					return
				entity.coins -= second_dice_price
				BattleManager.select_dice(dice_03_value)
		sfx.play()
