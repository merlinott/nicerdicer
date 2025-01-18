extends Control

@export var world : PackedScene

func _on_texture_rect_2_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		play()

func play() -> void: 
	var world_instance = world.instantiate()
	get_tree().root.add_child(world_instance)
	await get_tree().create_timer(.25).timeout
	queue_free()
