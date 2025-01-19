extends Control
@onready var hp_bar_under: TextureProgressBar = $HpBarUnder
@onready var hp_bar_shield: TextureProgressBar = $HpBarShield
@onready var hp_bar_health: TextureProgressBar = $HpBarHealth




func get_damage(dmg: int) -> void:
# Apply damage to the shield first
	if hp_bar_shield.value > 0:
		if dmg <= hp_bar_shield.value:
			tween_damage(hp_bar_shield, hp_bar_shield.value - dmg)
			
		else:
			var remaining_damage = dmg - hp_bar_shield.value
			tween_damage(hp_bar_health, hp_bar_health.value - remaining_damage)
			hp_bar_shield.value = 0
	else:
		# If no shield, apply damage directly to health
		tween_damage(hp_bar_health, hp_bar_health.value - min(dmg, hp_bar_health.value))
			

func set_hp_bar_shield(hp : int, shield : int) -> void:
	var full_value = hp + shield
	if full_value > hp_bar_health.max_value:
		hp_bar_health.max_value = full_value
		hp_bar_shield.max_value = full_value
	hp_bar_health.value = hp
	hp_bar_shield.value = full_value

func reset_hp_bar(val: int, fight_has_ended: bool = false) -> void:
	hp_bar_shield.max_value = val
	hp_bar_health.max_value = val
	hp_bar_shield.value = 0
	if fight_has_ended:
		hp_bar_health.value = val

func remove_shield():
	hp_bar_shield.value = 0



func tween_damage(bar : TextureProgressBar, value : int) -> void:
	var t = create_tween()
	t.tween_property(bar, "value", value, 0.4)
	
