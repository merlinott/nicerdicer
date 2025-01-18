extends Entity

func entity_ready() -> void:
	coins = 10
	max_life += max_life

func _physics_process(delta: float) -> void:
	if idle:
		return
		
	if is_attacking:
		label.text = str(life)
		velocity = Vector2.ZERO
		return
	
	label.text = str(max_life , is_attacking)
	
	
	
	if global_position.distance_to(get_global_mouse_position()) <= 100:
		return 


	velocity = global_position.direction_to(get_global_mouse_position()).normalized()
	velocity *= speed
	
	move_and_slide()
	
	
	if global_position.x >= get_global_mouse_position().x:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
		
