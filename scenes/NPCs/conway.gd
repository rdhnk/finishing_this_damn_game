extends Node2D

@onready var player := $"../../player"
@onready var player_cam := $"../../player/Camera2D"
var body_player
var player_in_chatzone = false
var resource = load("res://dialogues/conway1.dialogue")
@onready var dialogue_mark: Sprite2D = $chatzone/dialogue_mark

func _ready() -> void:
	DialogueManager.get_current_scene = func(): return get_node(".")
	DialogueManager.dialogue_ended.connect(_on_dialogue_manager_dialogue_ended) # For checking if a dialogue ended
	dialogue_mark.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if player_in_chatzone and Input.is_action_just_pressed("interact"):
		dialogue_mark.visible = false
		if player.dialogue_conway == 0:
			DialogueManager.show_dialogue_balloon(resource, "start")
			if player.climb_axe:
				player.dialogue_conway = 2
			else:
				player.dialogue_conway = 1
		elif player.dialogue_conway == 1:
			if player.climb_axe:
				DialogueManager.show_dialogue_balloon(resource, "yeaxe")
				player.dialogue_conway = 2
			else:
				DialogueManager.show_dialogue_balloon(resource, "noaxe")
		else:
			DialogueManager.show_dialogue_balloon(resource, "endloop")

func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body.name)
	if body.name == "player":
		player_in_chatzone = true
		dialogue_mark.visible = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	player_in_chatzone = false
	dialogue_mark.visible = false
	
func _on_dialogue_manager_dialogue_ended(resource: DialogueResource) -> void:
	# Code to execute when dialogue ends
	dialogue_mark.visible = true
