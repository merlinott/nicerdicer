extends Node

signal battle_started(entity1, entity2)
signal battle_ended(winner, loser)
signal player_input_received
signal picked_upgrade(number : int, index : int)

var battle_distance: float = 1000
var dice = DiceEngine.new()
var roll_amount: int = 1

var entities: Array = []
var entity_to_fill : Entity = null
var input_allowed : bool = false

var player : CharacterBody2D 
var player_roll : int = 0
var player_dice_type : int = 0

var damage_multiplier1 : int = 1
var damage_multiplier2 : int = 1

var game_ended : bool = false

func reset_manager():
	game_ended = false
	entities = []
	entity_to_fill = null
	player = null

func fill_entities(ents: Array) -> void:
	for i in ents:
		entities.append(i)
	
	var points : int = 0
	
	for i in 30:
		points += randi_range(0,5)
		var e = entities.pick_random()
		if e.is_player:
			return
		e.max_life += points
		
		
func add_enemie(instance : CharacterBody2D) -> void:
	entity_to_fill = instance


func roll_dice(sides: int) -> int:
	return dice.roll(roll_amount, sides)

func check_for_battles() -> void:
	if ! entity_to_fill == null:
		entities.append(entity_to_fill)
		entity_to_fill = null
		
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
	if game_ended:
		return
	entity1.is_attacking = true
	entity2.is_attacking = true
	
	entity1.fight_setup(entity2)
	entity2.fight_setup(entity1)
	entity1.unique_name.hide()
	entity2.unique_name.hide()
	
	
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
				
			await get_tree().create_timer(.1).timeout
			
			var dice_type1 = entity1.dice.throw_dice(roll1, entity1.dice_deck)
			var dice_type2 = entity2.dice.throw_dice(roll2, entity2.dice_deck)
			
			if entity1.is_player or entity2.is_player:
				player = entity1 if entity1.is_player else entity2
				var enemy = entity2 if entity1.is_player else entity1
				
				var t = create_tween()
				t.tween_property(enemy,"global_position", player.global_position + Vector2(1400,0), .5)
				await t.finished
				
				input_allowed = true
				player.set_dice_selection()
				player.dice_selection.show()
				
				await self.player_input_received
				if entity1.is_player:
					roll1 = player_roll
					dice_type1 = player_dice_type
					entity1.dice.set_dice_values(roll1, dice_type1)
					entity1.dice.show()
					
				if entity2.is_player:
					roll2 = player_roll
					dice_type2 = player_dice_type
					entity2.dice.set_dice_values(roll2, dice_type2)
					entity2.dice.show()
					
				
				player.dice_selection.hide()
				player.dice.show()
				
				
			set_abilities(dice_type1, dice_type2, entity1, entity2, roll1, roll2)
			
			roll1 *= damage_multiplier1
			roll2 *= damage_multiplier2
			
			entity1.attack() if roll1 + entity1.current_shield > roll2 + entity2.current_shield else entity2.attack()
			entity1.get_damage(roll2 - roll1) if roll1 < roll2 else entity2.get_damage(roll1 - roll2)
			await get_tree().create_timer(randf_range(.4,1)).timeout
			
			if game_ended:
				return
			if entity1.is_player:
				entity1.coins +=1  
			else:
				entity2.coins +=1
			
			
			if entity1.is_player or entity2.is_player:
				input_allowed = false
			
			damage_multiplier1 = 1
			damage_multiplier2 = 1
			
			entity1.dice.hide()
			entity2.dice.hide()
			entity1.hp_bar.hide()
			entity2.hp_bar.hide()
			entity1.label.hide()
			entity2.label.hide()
			
			entity1.end_round()
			entity2.end_round()
			
			
			
	var winner : Entity = entity1 if entity2.life <= 0 else entity2
	var loser : Entity = entity2 if winner == entity1 else entity1
	
	loser.unique_name.show()
	winner.unique_name.show()
	
	winner.won_fight()
	
	if !winner.is_player:
		winner.coins += loser.max_life
		winner.is_attacking = false
		winner.set_upgrade(randi_range(1, 6), randi_range(1,2))

	if !loser.is_player:
		loser.is_attacking = false
		
	var points : float = loser.max_life / 10
	points = ceil(points)
	
	if points == 0:
		points = 1
		
	winner.max_life += points
	
	loser.is_dead = true
	entities.append(winner)
	BattleManager.erase_assigned_name(loser.unique_name.text)
	loser.call_deferred("queue_free")
	if loser.is_player:
		lost_game()
		
	return loser


func set_abilities(dice_1 : int, dice_2 : int, entity1 : Entity, entity2 : Entity, roll1 : int, roll2 : int):
	entity1.reset()
	entity2.reset()

	if dice_1 == 1:
		entity1.set_shield(roll1)
		
	elif dice_1 == 2:
		damage_multiplier1 = 2

	#elif dice_1 == 2:
		#pass
	#elif dice_1 == 2:
		#pass
	#elif dice_1 == 2:
		#pass

	if dice_2 == 1:
		entity2.set_shield(roll2)
		
	elif dice_2 == 2:
		damage_multiplier2 = 2

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


# Predefined list of 500 unique names

# Set to track assigned names
var assigned_names = []

# Function to get a unique name
func get_unique_name() -> String:
	var new_name : String = ""
	while new_name == "":
		var n = unique_names.pick_random()
		if !assigned_names.has(n):
			assigned_names.append(n)
			new_name = n

	return new_name
# Clear assigned names (optional, for reuse or debugging)
func reset_names():
	assigned_names.clear()

func erase_assigned_name(n):
	assigned_names.erase(n)

func lost_game():
	var die_screen = load("res://scenes/die_screen.tscn")
	var die_screen_instance = die_screen.instantiate()
	reset_manager()
	await get_tree().create_timer(1.0).timeout
	get_tree().get_first_node_in_group("world").queue_free()
	get_tree().root.add_child(die_screen_instance)
	game_ended = true


var unique_names = [
	# Fantasy Names (500)
	"Aeloria", "Bryndal", "Caelwyn", "Davrek", "Elowen", "Faelith", "Garrion", "Halric", "Isolde", "Jorvan",
	"Kaelith", "Lirien", "Maevan", "Nythra", "Orelian", "Perdan", "Quendara", "Ryvarn", "Selthar", "Tyvian",
	"Umbrin", "Vaelith", "Wryndar", "Xandril", "Yavendra", "Zorvan", "Alleria", "Beryth", "Clyrin", "Draythen",
	"Ethra", "Feylin", "Galros", "Haldorin", "Ilvara", "Jareth", "Kivian", "Lysera", "Mordain", "Nythera",
	"Orynth", "Pylaris", "Qivrel", "Rhenira", "Sylorin", "Taldryn", "Uvenra", "Voryn", "Wynthera", "Xerian",
	"Ylvara", "Zalthar", "Aevlyn", "Braelyn", "Cynther", "Dorran", "Ellira", "Fennric", "Garnis", "Halyra",
	"Irelian", "Jandrel", "Kalther", "Lysira", "Malric", "Nythiel", "Orlith", "Pyral", "Qindra", "Raldin",
	"Syvrin", "Teryn", "Ulmara", "Veylin", "Wynden", "Xarion", "Yothren", "Zindrel", "Aelric", "Bryndis",
	"Caemir", "Daryon", "Elvenna", "Faelira", "Gryndal", "Havoren", "Ilvren", "Joral", "Klyra", "Lyneth",
	"Mordryn", "Nythorn", "Orynna", "Pyrith", "Qyvern", "Rynel", "Selrith", "Talneth", "Ulverin", "Vylaris",
	"Arlenor", "Barith", "Cindral", "Dorwyn", "Eryndel", "Falorin", "Gareth", "Helyra", "Irathis", "Joryth",
	"Kalden", "Lioren", "Meryth", "Naldor", "Orynthia", "Pyrran", "Qyros", "Rellion", "Synthera", "Tharindel",
	"Uryn", "Valdren", "Wythern", "Xalyth", "Yendral", "Zythera", "Alyndra", "Brislyn", "Caryth", "Dralyn",
	"Emberlyn", "Feyric", "Gristhar", "Halyndra", "Isrynn", "Jorvanis", "Kethar", "Lyrial", "Malven", "Nytherin",
	"Olenith", "Pyrrith", "Quarion", "Ryvlor", "Selvanis", "Theren", "Ulvaryn", "Varith", "Weylin", "Xylaris",
	"Yvereth", "Zandral", "Averic", "Brythen", "Calthor", "Drevan", "Elnorin", "Falthea", "Grynnar", "Haldreth",
	"Ilvoria", "Jandorin", "Kaeryth", "Lythan", "Maldor", "Neylin", "Olveris", "Pyralis", "Quindral", "Relyth",
	"Synara", "Talion", "Ulthera", "Vayron", "Wyvarin", "Xeryn", "Yeldrin", "Zarion", "Althorin", "Brelyth",
	"Cyvaris", "Drynth", "Eryndor", "Falyra", "Garethin", "Helryth", "Irithan", "Jorallis", "Kyveris", "Lyris",
	"Mendril", "Neryth", "Olythra", "Pyralyn", "Qyvarin", "Rindral", "Selvoris", "Therallis", "Ulveryn", "Varlyn",
	"Weylinar", "Xandros", "Ythira", "Zandryth", "Alerion", "Brythar", "Cindrell", "Dorathis", "Eryndrin", "Feylinar",
	"Garnal", "Halvris", "Ilvarin", "Jorynn", "Kaldorin", "Lorien", "Mythar", "Nythorin", "Orythia", "Pyrannis",
	"Qandral", "Ryndor", "Selithar", "Thalryn", "Ulvardis", "Varian", "Wytheris", "Xerith", "Yandral", "Zarvyn",
	"Andrenis", "Brynnis", "Ceryth", "Dalthor", "Elyra", "Falren", "Grendor", "Halyon", "Isorin", "Jorynnar",
	"Kalyth", "Lytheris", "Meyrith", "Neydris", "Orynith", "Pyrethor", "Quyran", "Rylanis", "Sylvren", "Talyron",
	"Ulyvaris", "Vernar", "Wyrnith", "Xavris", "Ythren", "Zarionis", "Alloryn", "Brinith", "Cayron", "Darlyth",
	"Eldrynn", "Feylinis", "Galvorn", "Heryn", "Irynth", "Jalvris", "Kyrin", "Lalvorn", "Melorin", "Naldorin",
	"Olytheris", "Paldris", "Qeryth", "Rendral", "Selvorn", "Thalvris", "Ulrynn", "Varnith", "Wyrialis", "Xendral",
	"Yrynn", "Zalvorn",

	# Real-Life Names (500)
	"Alexander", "Benjamin", "Charlotte", "Daniel", "Elizabeth", "Frederick", "Gabrielle", "Hannah", "Isabella", "Jacob",
	"Katherine", "Liam", "Mia", "Nathaniel", "Olivia", "Patrick", "Quinn", "Rebecca", "Samuel", "Thomas",
	"Ursula", "Victoria", "William", "Xavier", "Yvonne", "Zachary", "Allison", "Brian", "Catherine", "David",
	"Emily", "Franklin", "Grace", "Henry", "Irene", "James", "Kimberly", "Lucas", "Megan", "Nicholas",
	"Oliver", "Peter", "Quentin", "Rachel", "Sophia", "Timothy", "Ulysses", "Vanessa", "Wendy", "Xander",
	"Yasmin", "Zane", "Andrew", "Bethany", "Caroline", "Douglas", "Eleanor", "Fiona", "George", "Hazel",
	"Ian", "Jessica", "Kyle", "Lauren", "Margaret", "Noah", "Oscar", "Penelope", "Quincy", "Rose",
	"Sarah", "Theodore", "Uriah", "Valerie", "Wesley", "Xiomara", "Yvette", "Adam", "Beatrice", "Chloe",
	"Dominic", "Ethan", "Frances", "Gavin", "Holly", "Isabel", "Joseph", "Karen", "Lillian", "Matthew",
	"Natalie", "Owen", "Paul", "Ruth", "Simon", "Tara", "Uriel", "Victor", "Wayne", "Zelda", "Arthur",
	"Brooke", "Caleb", "Diana", "Edward", "Faith", "Gregory", "Heidi", "Julian", "Kara", "Logan",
	"Maxwell", "Nora", "Phillip", "Quinton", "Richard", "Sylvia", "Tessa", "Uma", "Wyatt", "Yolanda",
	"Zara", "Adrian", "Brianna", "Clara", "Derek", "Eva", "Felix", "Georgia", "Hunter", "Isla",
	"Jeremy", "Kenneth", "Lila", "Marshall", "Nina", "Oscar", "Preston", "Quinn", "Ryan", "Sophie",
	"Tyler", "Una", "Victor", "Whitney", "Ximena", "Zoe", "Austin", "Bella", "Cooper", "Daisy",
	"Evan", "Fiona", "Gage", "Harper", "Ian", "Jenna", "Kayla", "Levi", "Molly", "Natalia",
	"Owen", "Piper", "Quinn", "Reed", "Sadie", "Travis", "Uma", "Violet", "Wyatt", "Zoey",
	"Aaron", "Blake", "Cameron", "Diana", "Elliot", "Faith", "Giselle", "Hayden", "Ivy", "Jordan",
	"Kaitlyn", "Landon", "Madison", "Nathan", "Omar", "Paige", "Quincy", "Renee", "Seth", "Taylor",
	"Uriah", "Vivian", "Wesley", "Xander", "Yasmine", "Zachary", "Aiden", "Brielle", "Carson", "Dillon",
	"Emma", "Finn", "Gianna", "Hudson", "Isabel", "Jackson", "Kendall", "Lucy", "Mason", "Noah"
]
