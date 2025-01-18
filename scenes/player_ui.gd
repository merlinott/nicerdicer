extends CanvasLayer

@export var entity : Entity
@onready var current_coins: Label = $MarginContainer/HBoxContainer/CurrentCoins


func _ready() -> void:
	if entity.is_player:
		entity.collected_coin.connect(add_coin_value)
	
	
	
func _process(delta: float) -> void:
	current_coins.text = str(entity.coins)
	
func add_coin_value(value):
	pass
	#current_coins.text = str(value)
