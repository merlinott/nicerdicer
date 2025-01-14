extends Node2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func throw_dice(number : int) -> int:
	sprite.animation = (str(number))
	var rand = randf()
	if rand < 0.5:
		sprite.frame = 0
	else:
		sprite.frame = randi_range(0,1)
	
	return sprite.frame
