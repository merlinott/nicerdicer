class_name Entity
extends CharacterBody2D
@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var damage_numbers: Control = $DamageNumbers
@onready var dice: Node2D = $Dice
@onready var hp_bar: Control = $hp_bar


@export var speed : float = 3000
@onready var sprite: Sprite2D = $Sprite2D

@export var is_player : bool = false
var is_dead = false
var is_attacking = false
var sides : int = 6
var max_life : int = 0
var life : int = 0

var shield : bool = false#devides the damage by 2 
var current_shield : int = 0

var idle : bool = true


func _ready() -> void:
	animation_player.play("RESET")
	entity_ready()
	max_life = sides
	if is_player: 
		max_life *= 2
	await  get_tree().create_timer(2).timeout
	idle = false
	animation_player.play("walk")
	
	
func entity_ready() -> void:
	pass


func fight_setup(enemy : CharacterBody2D): 
	if is_player:
		var value = %Camera2D.zoom * 2
		tween_cam(value)
		
	life = max_life
	hp_bar.reset_hp_bar(life)
	if global_position.x >= enemy.global_position.x:
		sprite.scale.x = -1
	else:
		sprite.scale.x = 1
		
	animation_player.play("RESET")

	
func get_damage(damage: int):
	if shield:
		animation_player.play("shield")
		current_shield -= damage  # Subtract damage from the shield first
		hp_bar.get_damage(damage)
		if current_shield < 0:  # If shield is depleted
			var remaining_damage = -current_shield  # Convert to positive excess damage
			current_shield = 0  # Set shield value to zero
			life -= remaining_damage  # Apply remaining damage to life
			hp_bar.get_damage(damage)
			damage_numbers.setup(damage)
		if current_shield == 0:  # Deactivate shield when depleted
			shield = false
	else:
		if damage > life:
			hp_bar.get_damage(life)
			damage_numbers.setup(life)
		else:
			hp_bar.get_damage(damage)
			damage_numbers.setup(damage)
		life -= damage  # Directly apply damage to life when shield is inactive
		
	if life < 0:  # Ensure life doesn't go below 0
		life = 0

func attack():
	animation_player.play("attack_01")


func set_shield(value : int):
	label.modulate = Color.AQUA
	shield = true
	current_shield = value
	hp_bar.set_hp_bar_shield(life, value)


func won_fight():
	animation_player.play("walk")
	hp_bar.reset_hp_bar(max_life)
	if is_player:
		var value = %Camera2D.zoom / 2
		tween_cam(value)
		
func reset():
	label.modulate = Color.WHITE
	shield = false

func end_round():
	hp_bar.remove_shield()


func _process(delta: float) -> void:
	if is_attacking:
		if shield:
			label.text = str(life + current_shield)
		else:
			label.text = str(life)
	else:
		label.text = str(max_life)


func tween_cam(value):
	var t = create_tween()
	t.tween_property(%Camera2D,"zoom",value,.2)
