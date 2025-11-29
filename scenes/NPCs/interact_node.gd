extends Node2D

@onready var player := get_tree().current_scene.get_node("player") # get player from tree
@onready var player_cam := get_tree().current_scene.get_node("player/Camera2D") # get player camera from tree
@onready var npc := get_parent() # get NPC/object sprite for dialogue logic
@onready var dialogue_mark: Sprite2D = $DialogueMark

var player_in_chatzone = false
#@onready var original_cam_y : float = player_cam.position.y
var chatzone_cam_y : float = 30 # Increase the cam height during interaction

func _ready() -> void:
	DialogueManager.get_current_scene = func(): return get_node(".")
	DialogueManager.dialogue_ended.connect(_on_dialogue_manager_dialogue_ended) # For checking if a dialogue ended
	#dialogue_mark.visible = false
	#print(dialogue_mark.visible)

func _unhandled_input(event: InputEvent) -> void:
	if player_in_chatzone and Input.is_action_just_pressed("interact"):
		dialogue_mark.visible = false
		player.can_move = false
		player.velocity.x = 0
		player_cam.zoom = Vector2(6.0, 6.0)
		player_cam.position.y += chatzone_cam_y
		print(player_cam.position.y)
		# Call dialogue from npc node
		npc.dialogue_logic()

func _on_chatzone_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player_in_chatzone = true
		dialogue_mark.visible = true
		print(player_cam.position.y)

func _on_chatzone_body_exited(body: Node2D) -> void:
	player_in_chatzone = false
	dialogue_mark.visible = false
	
func _on_dialogue_manager_dialogue_ended(resource: DialogueResource) -> void:
	# Code to execute when dialogue ends
	dialogue_mark.visible = true
	# TODO: lines below will be run from every interact_node out there
	# For example: if I made 20 NPCs, then the lines will be run 20 times
	# Possible performance hit, when there are lots of NPCs
	player.can_move = true
	player_cam.zoom = Vector2(4.0, 4.0)
	player_cam.position.y = player.ori_cam_y
	print(player_cam.position.y)
