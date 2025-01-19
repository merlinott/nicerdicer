extends Control

@export var button: Button 
@export var button_2: Button

func _ready() -> void:
	button.pressed.connect(on_menu_pressed)
	button_2.pressed.connect(on_try_again_pressed)
	
func on_menu_pressed():
	var menu_scene = load("res://scenes/main_menu.tscn")
	var menu_instance = menu_scene.instantiate()
	get_tree().root.add_child(menu_instance)
	queue_free()
	
func on_try_again_pressed():
	play()

func play() -> void: 
	var world_scene = load("res://scenes/world.tscn")
	var world_instance = world_scene.instantiate()
	get_tree().root.add_child(world_instance)
	queue_free()
