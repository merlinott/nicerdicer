extends Control
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var label: Label = $Label




func setup(dmg : int) -> void:
	label.text = str(dmg)
	animation_player.play("default")
