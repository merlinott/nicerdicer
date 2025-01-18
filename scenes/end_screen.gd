extends Control

@export var button: Button 
@export var button_2: Button
@export var world : PackedScene

func _ready() -> void:
	button.pressed.connect(on_menu_pressed)
	button_2.pressed.connect(on_try_again_pressed)
	
func on_menu_pressed():
	get_tree().reload_current_scene()
	
func on_try_again_pressed():
	play()

func play() -> void: 
	var world_instance = world.instantiate()
	get_tree().root.add_child(world_instance)
	queue_free()
