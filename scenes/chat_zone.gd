extends Area2D

@onready var player := get_tree().current_scene.get_node("player") # get player from tree
@onready var player_cam := get_tree().current_scene.get_node("player/Camera2D") # get player camera from tree
@onready var npc := get_parent() # get NPC/object sprite for dialogue logic
@onready var chat_balloon: Sprite2D = get_parent().get_node("ChatZone/ChatBalloon")

var current_npc_name : String # Get the NPC parent name. Very important
var player_in_chatzone = false
var chatzone_cam_y : float = 20 # Increase the cam height during interaction

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	chat_balloon.visible = false
	DialogueManager.get_current_scene = func(): return get_node(".")
	DialogueManager.dialogue_ended.connect(_on_dialogue_manager_dialogue_ended) # For checking if a dialogue ended

func _unhandled_input(event: InputEvent) -> void:
	if player_in_chatzone and Input.is_action_just_pressed("interact"):
		chat_balloon.visible = false
		player.can_move = false
		player.velocity.x = 0
		player_cam.zoom = Vector2(6.0, 6.0)
		player_cam.position.y += chatzone_cam_y
		print(player_cam.position.y)
		# Call dialogue from npc node
		npc.dialogue_logic()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player_in_chatzone = true
		chat_balloon.visible = true
		print(chat_balloon.visible)
		current_npc_name = npc.name
		#print(current_npc_name)

func _on_body_exited(body: Node2D) -> void:
	if body.name == "player":
		player_in_chatzone = false
		chat_balloon.visible = false
		current_npc_name = ""
		print(chat_balloon.visible)
		
func _on_dialogue_manager_dialogue_ended(resource: DialogueResource) -> void:
	# Code to execute when dialogue ends, globally
	# It activates every ChatBalloon for every ChatZones
	
	# It checks if the current NPC name is the exact NPC the player is currently talked with
	# Why? Because this function happens GLOBALLY, so it runs these lines below for EVERY NPCs
	# For example, if a dialogue ends, the ChatBalloon in EVERY NPCs will be visible
	# So if there are 20 NPCs, all of them will have their balloon visible
	# It's a possible performance hit, when there are lots of NPCs
	# This "hack" ensure that the code only runs on the exact NPC the player just talked with
	# It's still a hack, since it's still checks every NPCs. But it works, for now.
	# Why did I wrote this? Because it took me 3 days to solve and it drove me INSANE.
	if npc.name == current_npc_name:
		chat_balloon.visible = true
		player.can_move = true
		player_cam.zoom = Vector2(4.0, 4.0)
		player_cam.position.y = player.ori_cam_y
		print(player_cam.position.y)
