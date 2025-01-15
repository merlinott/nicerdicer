extends Node2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func throw_dice(number : int, dice_deck : Array) -> int:
	sprite.animation = (str(number))
	var rand = randf()
	if rand < 0.5:
		sprite.frame = 0
	else:
		var side = dice_deck[number - 1][1].pick_random()
		sprite.frame = side
	
	return sprite.frame

func get_dice_texture(animation_name : int, frame_index : int) -> Texture2D:
	var sprite_frames: SpriteFrames = sprite.get_sprite_frames()
	var current_texture: Texture2D = sprite_frames.get_frame_texture(str(animation_name), frame_index)
	
	return current_texture


func set_dice_values(anim : int, type : int) -> void:
	if anim == 0:
		return
	sprite.animation = str(anim)
	sprite.frame = type
	
