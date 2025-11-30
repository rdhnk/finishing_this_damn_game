extends Node2D

@export var rest_length = 5.0	# Line length. Higher means longer line
@export var stiffness = 40.0	# Higher means faster to pull
@export var damping = 5.0		# Higher means less bouncy

@onready var player := get_parent()
@onready var ray := $RayCast2D
@onready var rope := $Line2D
@onready var point := $RayCast2D/PointSprite

var launched = false
var target: Vector2
var mover = Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if player.grappling_hook:
		# use mouse to aim
		#ray.look_at(get_global_mouse_position())

		#ray.target_position.x = 30.0 * player.direction
		#ray.target_position.x = lerp(ray.target_position.x, 30.0 * player.direction, 0.3)
		#point.position.x = lerp(point.position.x, 30.0 * player.direction, 0.3)
		ray.global_rotation_degrees = lerp(ray.global_rotation_degrees, rad_to_deg(mover.angle()) - (-45.0 * player.direction),0.3)
		
		point.visible = true
		# Change pointer color if it's colliding
		if ray.is_colliding():
			point.self_modulate = Color(0, 1, 0, 1)
		else:
			point.self_modulate = Color(1, 1, 1, 1)	

		if InputBuffer.is_action_press_buffered("move_grapple"): # Using custom InputBuffer. Hopefully make the grappling timing to be less frame-perfect
			print("grapple pressed")
			launch()
		if Input.is_action_just_released("move_grapple"):
			retract()
			
		if launched:
			handle_grapple(delta)
	else:
		point.visible = false

func launch():
	if ray.is_colliding():
		launched = true
		print("grapple launched")
		target = ray.get_collision_point()
		player.player_sprite.play("grapple")
		rope.show()
	
func retract():
	launched = false
	rope.hide()
	
func handle_grapple(delta):
	var target_dir = player.global_position.direction_to(target)
	var target_dist = player.global_position.distance_to(target)
	
	var displacement = target_dist - rest_length
	var force = Vector2.ZERO
	
	if displacement > 0:
		var spring_force_magnitude = stiffness * displacement
		var spring_force = target_dir * spring_force_magnitude
		
		var vel_dot = player.velocity.dot(target_dir)
		var damping = -damping * vel_dot * target_dir
		
		force = spring_force + damping
	
	player.velocity += force * delta
	update_rope()
	
func update_rope():
	rope.set_point_position(1, to_local(target))
