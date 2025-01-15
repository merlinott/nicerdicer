extends Node2D

@onready var enemy_container: Node2D = $EnemyContainer
const ENEMY = preload("res://scenes/enemy.tscn")

func _ready() -> void:
	spanw_enemies(0)
	
func _process(delta: float) -> void:
	await get_tree().create_timer(.1).timeout
	BattleManager.check_for_battles()

func spanw_enemies(num : int) -> void:
	for i in num:
		var instance = ENEMY.instantiate()
		instance.global_position = Vector2(randf_range(-5000,5000),randf_range(-5000,5000))
		enemy_container.add_child(instance)

	BattleManager.fill_entities(enemy_container.get_children())
