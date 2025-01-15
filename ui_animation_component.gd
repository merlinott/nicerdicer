extends Node
class_name UIAnimationComponent

@export var from_center : bool = false
@export var gui_input_fadeout : bool = false
@export var hover_scale : Vector2 = Vector2(1.0, 1.0)	
@export var anim_duration : float = 0.1
@export var transition_type : Tween.TransitionType

var target : Control
var default_scale : Vector2


func _ready():
	target = get_parent()
	call_deferred("setup")
	connect_signals()


func connect_signals()-> void:
	target.connect("mouse_entered", on_hover)
	target.connect("mouse_exited", off_hover)
	target.connect("gui_input", gui_input)


func setup() -> void:
	if from_center:
		target.pivot_offset = target.size / 2
	default_scale = target.scale

func on_hover() -> void:
	add_twenn("scale", hover_scale, anim_duration)


func off_hover() -> void:
	add_twenn("scale", default_scale, anim_duration)


func add_twenn(property : String, value, duration : float) -> void:
	var t = get_tree().create_tween()
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_property(target, property, value, duration).set_trans(transition_type)


func gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if gui_input_fadeout:
				var t = get_tree().create_tween()
				t.tween_property(target,"scale", Vector2.ZERO, anim_duration).set_trans(Tween.TRANS_ELASTIC)
