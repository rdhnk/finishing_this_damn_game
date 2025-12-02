extends CharacterBody2D

# Player
@onready var player = get_node("/root/")
@onready var player_sprite: AnimatedSprite2D = $player_sprite  # put player sprite into variable
@onready var player_camera: Camera2D = $Camera2D

# Axis & position
var direction : float = 0.0
@onready var respawn_position : Vector2 = get_global_position()

# Constant variables
const SPEED : float = 100.0
#const STOP_SPEED : float = 8.0 # the lower the value, the heavier player movement is
const ACCELERATION = 0.1
const DECELERATION = 0.1
const GRAVITY : float = 900.0
const MAX_FALL_SPEED : float = 800.0
const JUMP_VELOCITY : float  = -300.0
const JUMP_CUT_MULTIPLIER : float  = 0.4
const COYOTE_DURATION : float  = 0.1
const JUMP_BUFFER_DURATION : float  = 0.15
const WALL_SLIDE_SPEED: float = 55.0
const WALL_JUMP_H_FORCE: float = 160.0
const WALL_JUMP_V_FORCE: float = -260.0
const WALL_STICK_TIME: float = 0.15  # optional grace time after leaving wall

# state variables
var coyote_timer : float  = 0.0
var jump_buffer_timer : float  = 0.0
var wall_stick_counter: float = 0.0
var is_wall_sliding : bool = false
var wall_dir : float = 0  # -1 = left wall, +1 = right wall
var wall_touching_left : bool = false
var wall_touching_right : bool = false

# items
var climb_boots : bool = true # for wall slide & wall climb
var grappling_hook : bool = true # for grappling hook
var parachute : bool = true # for parachute
#var quick_hook : bool = false
@onready var climbing_boots_sprite: Sprite2D = $Items/ClimbingBoots
@onready var sfx_get_item: AudioStreamPlayer2D = $sfx/sfx_get_item

# get grappling controller
@onready var grapple_controller: Node2D = $GrappleController
# for checking walls, using Raycast
@onready var wall_check_left: RayCast2D = $WallChecking/WallCheckLeft
@onready var wall_check_right: RayCast2D = $WallChecking/WallCheckRight

# parachute
var is_parachuting : bool = false
@onready var sprite_parachute: Sprite2D = $Items/Parachute

# Health & move status
var alive : bool = true # as in, not dead
var to_die : bool = false # if it's true, then dead is imminent
var falldeath_threshold : float = 600.0
@onready var death_time: Timer = $DeathTime # delay timer before restarting
var can_move : bool = true # whether player can move or not
@onready var respawn_label: Label = $RespawnLabel

# Camera manipulation
var look_direction : float = 0.0
var cam_pressed : bool = false
var cam_hold_time := 0.0
var cam_threshold := 0.6  # seconds
var cam_y : float = 80
var ori_cam_y : float = -20.0

# Sound effects
@onready var sfx_jump := $sfx/sfx_jump
@onready var sfx_fall := $sfx/sfx_fall
@onready var sfx_run := $sfx/sfx_run
@onready var sfx_die: AudioStreamPlayer2D = $sfx/sfx_die
var sfx_fall_played : bool = false
var sfx_die_played : bool = false
@onready var running_time: Timer = $RunningTime

# Dialogue checks
var dialogue_hardy : int = 0
var dialogue_conway : int = 0
var has_meet_hardy : bool = 0
var dialogue_shop_gauss : int = 0

func _physics_process(delta: float) -> void:
	if can_move:
		dying() # at every moment, you have to ask yourself whether you're alive
		
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		if alive:
			direction = Input.get_axis("move_left", "move_right")
		# Flipping player sprite, based on left-right direction
		if direction < 0:
			player_sprite.flip_h = true
		elif direction > 0:
			player_sprite.flip_h = false
			
		if direction and wall_stick_counter <= 0.0:
			#velocity.x = move_toward(velocity.x, direction * SPEED, STOP_SPEED)
			velocity.x = lerp(velocity.x, direction * SPEED, ACCELERATION)
			#print("x = ", velocity.x)
			if is_on_floor() and alive:
				player_sprite.play("run")
				if !sfx_run.playing:
					sfx_run.pitch_scale = randf_range(0.45, 0.5)
					sfx_run.play()
		else:
			#velocity.x = move_toward(velocity.x, 0, STOP_SPEED - 2.0)e
			if alive:
				velocity.x = lerp(velocity.x, 0.0, DECELERATION)
				player_sprite.play("idle")
		
		# move camera up or down
		cam_look(delta)
		
		# Record jump input
		if Input.is_action_just_pressed("move_jump") and alive:
			sfx_jump.play()
			jump_buffer_timer = JUMP_BUFFER_DURATION
		# Check wall contact (using collision normals)
		wall_touching_left = wall_check_left.is_colliding()
		wall_touching_right = wall_check_right.is_colliding()
		is_wall_sliding = false
		wall_dir = 0
		# Check if it's on the air
		#print("y = ",velocity.y)
		if not is_on_floor() and alive:
			# Add the gravity.
			velocity.y += GRAVITY * delta
			if velocity.y >= MAX_FALL_SPEED:
				velocity.y = MAX_FALL_SPEED
			if grapple_controller.launched:
				player_sprite.play("grapple")
			else:
				player_sprite.play("jump")
				if velocity.y < 0:
					player_sprite.set_frame_and_progress(0, 1)
				elif velocity.y > 0:
					player_sprite.set_frame_and_progress(1, 1)
			# Checking wall direction
			if wall_touching_left:
				wall_dir = 1
				is_wall_sliding = true
			elif wall_touching_right:
				wall_dir = -1
				is_wall_sliding = true
			# Dying by falling
			if velocity.y >= falldeath_threshold: # it needs to be falling down fast ...
				player_sprite.play("fall_panic")
				if !to_die:			# ... and you will be flagged to die ONCE
					to_die = true
				if !sfx_fall_played:	# Play the panic SFX just ONCE
					sfx_fall_played = true
					sfx_fall.play()
			if to_die and (is_wall_sliding or grapple_controller.launched or is_parachuting): # Save yourself by wall sliding or grappling
				to_die = false
		else:
			velocity.y = 0.0
		if to_die and is_on_floor(): # If to_die is true, you will die only if you hit the floor
				alive = false
		#print("vel: x ", velocity.x," y ",velocity.y," touch wall? ",is_on_wall())
		#print(wall_stick_counter)
				
		# Timer logic
		if alive and (is_on_floor() or grapple_controller.launched):
			coyote_timer = COYOTE_DURATION  # reset when touching the ground or while using grappling hook
		else:
			coyote_timer -= delta       	# countdown when in air
		if jump_buffer_timer > 0.0:
			jump_buffer_timer -= delta
		if wall_stick_counter > 0.0:
			wall_stick_counter -= delta

		# Normal jump
		if (coyote_timer > 0 and jump_buffer_timer > 0): # will jump only if player has coyote & jump buffer time
			velocity.y = JUMP_VELOCITY
			#print(velocity.x, velocity.y)
			coyote_timer = 0.0  		# consume coyote time
			jump_buffer_timer = 0.0		# consume jump buffer time
			grapple_controller.retract() # if jumping while using grappling hook, it retracts
		# Wall jumping
		wall_jumping(climb_boots)
		# Variable jump height
		if Input.is_action_just_released("move_jump") and velocity.y < 0.0:
			velocity.y *= JUMP_CUT_MULTIPLIER
		# Parachuting
		activate_parachute()
		
		if alive:
			move_and_slide()
	
func dying():
	if !alive:
		player_sprite.play("dead")
		respawn_label.visible = true
		#velocity = Vector2.ZERO
		#velocity.x = lerp(velocity.x, 0.0, DECELERATION)
		if !sfx_die_played:	# Play the panic SFX just ONCE
			sfx_die_played = true
			sfx_die.play()
			print("ded")
		#if Input.is_anything_pressed(): # press any key to restart
		if Input.is_action_just_pressed("interact"): # press E/X to restart
			set_global_position(respawn_position)
			alive = true
			to_die = false
			sfx_fall_played = false
			sfx_die_played = false
			respawn_label.visible = false
			#get_tree().reload_current_scene()
		#death_time.start()

func wall_jumping(climbboots : bool) -> void:
	if !climbboots:
		pass
	else:
		# Wall slide
		if is_wall_sliding:
			player_sprite.play("wall_slide")
			if wall_touching_left:
				player_sprite.flip_h = false
			else:
				player_sprite.flip_h = true
			if velocity.y > WALL_SLIDE_SPEED:
				velocity.y = WALL_SLIDE_SPEED
		# Wall jump
		if is_wall_sliding and Input.is_action_just_pressed("move_jump"):
			velocity.x = WALL_JUMP_H_FORCE * wall_dir
			velocity.y = WALL_JUMP_V_FORCE
			is_wall_sliding = false
			coyote_timer = 0.0
			jump_buffer_timer = 0.0
			wall_stick_counter = WALL_STICK_TIME # So horizontal input turned off temporary after wall jump
			player_sprite.flip_h = !player_sprite.flip_h
			
func activate_parachute():
	if !parachute:
		pass
	else:
		if Input.is_action_pressed("parachute") and !is_on_floor() and !grapple_controller.launched:
			is_parachuting = true
			player_sprite.play("grapple")
			sprite_parachute.visible = true
			velocity.y = lerp(velocity.y, 20.0, 0.3)
		else:
			is_parachuting = false
			sprite_parachute.visible = false

func cam_look(delta):
	if Input.is_action_pressed("look_up") or Input.is_action_pressed("look_down"):
		look_direction = Input.get_axis("look_up", "look_down")
		cam_hold_time += delta
		if cam_hold_time >= cam_threshold:
			if !cam_pressed:
				player_camera.position.y += look_direction * cam_y
				cam_pressed = true
	elif Input.is_action_just_released("look_up") or Input.is_action_just_released("look_down"):
		cam_hold_time = 0.0
		player_camera.position.y = ori_cam_y
		cam_pressed = false

#func _on_death_time_timeout() -> void:
	##alive = true
	#get_tree().reload_current_scene()
	#

func _on_transit_to_1_body_entered(body: Node2D) -> void:
	if body.name == "player":
		get_tree().change_scene_to_file("res://scenes/level_1.tscn")
