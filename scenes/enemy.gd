extends Entity

var wander_theta := 0.0
var wander_theta_target := 0.0

#random wandering
var wander_circle_center := Vector2.ZERO
var wander_target := Vector2.ZERO
var wander_steer := Vector2.ZERO


const WANDER_CIRCLE_DISTANCE = 2000  # Distance to the wander circle
const WANDER_CIRCLE_RADIUS = 1000     # Radius of the wander circle
const WANDER_ANGLE_CHANGE = 0.25     # How fast the wander angle changes


@export_enum("Agressive","Defensive","NeutralAgressive", "NeutralDefessive") var enemy_behaviour = 1



func entity_ready() -> void:
	velocity = Vector2.RIGHT.rotated(deg_to_rad(randi_range(0,360)))
	#velocity = Vector2.UP

func _physics_process(delta: float) -> void:
	if idle:
		return
		

	if is_attacking:
		velocity = Vector2.ZERO
		return
	
		
	var new_wander_steer = wander(velocity.rotated(deg_to_rad(randf_range(-5,5))))
	velocity = wander_steer.lerp(new_wander_steer, 0.05)  # Smooth the wandering steer
	
	# Adjust the velocity and move at the correct speed
	velocity = velocity.normalized() * speed
	move_and_slide()



func wander(movement_direction: Vector2) -> Vector2:
	randomize()
	# 1. Find the point on the wander circle ahead of the character
	wander_circle_center = movement_direction * WANDER_CIRCLE_DISTANCE
	
	# 2. Randomly adjust the wander angle (a smooth random walk)
	wander_theta_target += randf_range(-WANDER_ANGLE_CHANGE, WANDER_ANGLE_CHANGE)
	wander_theta = lerp(wander_theta, wander_theta_target, 0.05)  # Smoothing the theta change
	
	# 3. Calculate the new point on the circle using the updated angle
	var wander_offset = Vector2(
		WANDER_CIRCLE_RADIUS * cos(wander_theta),
		WANDER_CIRCLE_RADIUS * sin(wander_theta)
	)
	
	# 4. Calculate the target point by adding the offset to the circle's center
	wander_target = wander_circle_center + wander_offset
	
	# 5. Calculate the steering force towards the wander target
	var steer = wander_target - movement_direction
	return steer.normalized()
