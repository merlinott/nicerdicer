extends Node2D

@onready var top_10_label: RichTextLabel = %Top10Label
@onready var enemy_container: Node2D = $EnemyContainer
@onready var coin_container: Node2D = $CoinContainer


const ENEMY = preload("res://scenes/enemy.tscn")
const COIN = preload("res://scenes/coin.tscn")

var enemy_t : float = 0
var coin_t : float = 0

var leading_enemy : Entity = null

func _ready() -> void:
	spawn_enemy(250)
	spawn_coin(50)
	
func _process(delta: float) -> void:
	await get_tree().create_timer(.1).timeout
	BattleManager.check_for_battles()
	
	enemy_t+= delta
	if enemy_t > 0.250:
		spawn_single_enemy()
		enemy_t = 0.0
		

	coin_t+= delta
	if coin_t > 1.0:
		spawn_single_coin()
		coin_t = 0.0
		
		#print("TOTAL ENTITIES : ", enemy_container.get_children().size())
	check_entity_points()


func check_entity_points():
	var enemies = []
	
	# Collect all enemies in the container
	for i in enemy_container.get_children():
		enemies.append(i)
	
	# Sort the enemies based on max_life in descending order
	enemies.sort_custom(_sort_max_life_desc)
	
	# Display the top 10 enemies
	var top_10 = enemies.slice(0, 10)  # Get the first 10 enemies
	
	# Make sure the Label has BBCode enabled
	top_10_label.set("bbcode_enabled", true)
	
	# Create the list with colored text for players
	var list_text = ""
	var rank = 1
	for enemy in top_10:
		var rank_str = str(rank) + ". "  # Add period after number
		if enemy.is_player:
			list_text += "[color=#FFD700]" + rank_str + str(enemy.unique_name.text) + " - " + str(enemy.max_life) + "[/color]\n"
		else:
			list_text += rank_str + str(enemy.unique_name.text) + " - " + str(enemy.max_life) + "\n"
		rank += 1
	# Set the BBCode text
	top_10_label.text = list_text

# Custom sorting function for sorting based on max_life in descending order
func _sort_max_life_desc(a, b):
	return a.max_life > b.max_life  # Just return true/false

func spawn_enemy(num : int) -> void:
	for i in num:
		var instance = ENEMY.instantiate()
		instance.global_position = Vector2(randf_range(-30000,30000),randf_range(-30000,30000))
		enemy_container.add_child(instance)

	BattleManager.fill_entities(enemy_container.get_children())


func spawn_single_enemy() -> void:
	var instance = ENEMY.instantiate()
	instance.global_position = Vector2(randf_range(-30000,30000),randf_range(-30000,30000))
	enemy_container.add_child(instance)

	BattleManager.add_enemie(instance)


func spawn_coin(num : int) -> void:
	for i in num:
		var instance = COIN.instantiate()
		instance.global_position = Vector2(randf_range(-30000,30000),randf_range(-30000,30000))
		coin_container.add_child(instance)


func spawn_single_coin() -> void:
	var instance = COIN.instantiate()
	instance.global_position = Vector2(randf_range(-30000,30000),randf_range(-30000,30000))
	coin_container.add_child(instance)
