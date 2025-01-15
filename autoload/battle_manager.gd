extends Node

signal battle_started(entity1, entity2)
signal battle_ended(winner, loser)
signal player_input_received

var battle_distance: float = 1000
var dice = DiceEngine.new()
var roll_amount: int = 1

var entities: Array = []
var input_allowed : bool = false

var player : CharacterBody2D 
var player_roll : int = 0
var player_dice_type : int = 0


func fill_entities(ents: Array) -> void:
	for i in ents:
		entities.append(i)

func roll_dice(sides: int) -> int:
	return dice.roll(roll_amount, sides)

func check_for_battles() -> void:
	for i in entities.size():
		for j in range(i + 1, entities.size()):  # Ensure j > i
			if entities[i].is_attacking or entities[j].is_attacking: return

			var entity1 = entities[i]
			var entity2 = entities[j]

			if entity1.global_position.distance_to(entity2.global_position) <= battle_distance:
				if entities[i].is_dead or entities[j].is_dead: return
				if entity1.idle or entity2.idle: continue
				if entity1.is_attacking or entity2.is_attacking: continue
				entities.erase(entity1)
				entities.erase(entity2)
				start_battle(entity1, entity2)
				return 


func start_battle(entity1: Entity, entity2: Entity) -> Entity:
	
	entities.erase(entity1)
	entities.erase(entity2)
	
	entity1.is_attacking = true
	entity2.is_attacking = true
	entity1.fight_setup(entity2)
	entity2.fight_setup(entity1)
	

	while entity1.life > 0 and entity2.life > 0:
		var roll1 = roll_dice(entity1.sides)
		var roll2 = roll_dice(entity2.sides)
		
		
		if roll1 != roll2:
				
			entity1.hp_bar.show()
			entity2.hp_bar.show()
			entity1.label.show()
			entity2.label.show()

			if !entity1.is_player:
				entity1.dice.show()
			if !entity2.is_player:
				entity2.dice.show()
				
			await get_tree().create_timer(.25).timeout
			
			var dice_type1 = entity1.dice.throw_dice(roll1, entity1.dice_deck)
			var dice_type2 = entity2.dice.throw_dice(roll2, entity2.dice_deck)
			
			if entity1.is_player or entity2.is_player:
				player = entity1 if entity1.is_player else entity2
				input_allowed = true
				player.set_dice_selection()
				player.dice_selection.show()
				
				await self.player_input_received
				
				if entity1.is_player:
					roll1 = player_roll
					dice_type1 = player_dice_type
					entity1.dice.set_dice_values(roll1, dice_type1)
					print("num: ", entity1.dice.sprite.animation, "type: ", entity1.dice.sprite.frame)
					entity1.dice.show()
					
				if entity2.is_player:
					roll2 = player_roll
					dice_type2 = player_dice_type
					entity2.dice.set_dice_values(roll2, dice_type2)
					print("num: ", entity2.dice.sprite.animation, "type: ", entity2.dice.sprite.frame)
					entity2.dice.show()
					
				
				player.dice_selection.hide()
				player.dice.show()
			
			set_abilities(dice_type1, dice_type2, entity1, entity2, roll1, roll2)
			
			entity1.attack() if roll1 > roll2 else entity2.attack()
			entity1.get_damage(roll2 - roll1) if roll1 < roll2 else entity2.get_damage(roll1 - roll2)
			await get_tree().create_timer(0.75).timeout
			
			if entity1.is_player or entity2.is_player:
				input_allowed = false
			
			entity1.dice.hide()
			entity2.dice.hide()
			entity1.hp_bar.hide()
			entity2.hp_bar.hide()
			entity1.label.hide()
			entity2.label.hide()
			
			entity1.end_round()
			entity2.end_round()
			
	var winner = entity1 if entity2.life <= 0 else entity2
	var loser = entity2 if winner == entity1 else entity1

	winner.won_fight()
	winner.is_attacking = false
	loser.is_attacking = false

	winner.max_life += loser.max_life
	loser.is_dead = true
	entities.append(winner)
	loser.call_deferred("queue_free")
	return loser


func set_abilities(dice_1 : int, dice_2 : int, entity1 : Entity, entity2 : Entity, roll1 : int, roll2 : int):
	entity1.reset()
	entity2.reset()

	if dice_1 == 1:
		entity1.set_shield(roll1)
		
	elif dice_1 == 2:
		pass

	#elif dice_1 == 2:
		#pass
	#elif dice_1 == 2:
		#pass
	#elif dice_1 == 2:
		#pass

	if dice_2 == 1:
		entity2.set_shield(roll2)
		
	elif dice_2 == 2:
		pass

	#elif dice_2 == 2:
		#pass
	#elif dice_2 == 2:
		#pass
	#elif dice_2 == 2:
		#pass


func select_dice(dice_data : Array):
	player_roll = dice_data[0]
	player_dice_type = dice_data[1]
	player_input_received.emit()
