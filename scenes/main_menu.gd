extends Node2D

@export var world : PackedScene
@onready var button: Sprite2D = $ButtonHandler/Button
@onready var button_area: Area2D = $ButtonHandler/Button/Area2D
@onready var button_handler: Node2D = $ButtonHandler


func _ready() -> void:
	button_area.mouse_entered.connect(on_play_button_entered)
	button_area.mouse_exited.connect(on_play_button_exited)

func on_play_button_entered() -> void:
	button_handler.scale = Vector2(1.05, 1.05)
	
func on_play_button_exited() -> void:
	button_handler.scale = Vector2(1.0, 1.0)

func play() -> void: 
	var world_instance = world.instantiate()
	get_tree().root.add_child(world_instance)
	await get_tree().create_timer(.25).timeout
	queue_free()

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		play()
