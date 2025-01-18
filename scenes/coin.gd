extends Area2D


func _ready() -> void:
	body_entered.connect(collect)


func collect(body) -> void:
	if body is Entity:
		if body.is_player:
			body.coins += randi_range(5,10)
			queue_free()
