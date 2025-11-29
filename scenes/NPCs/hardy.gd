extends Node2D

@onready var player := $"../../player"
@onready var player_cam := $"../../player/Camera2D"
var body_player
var player_in_chatzone = false
var resource = load("res://dialogues/hardy1.dialogue")
@onready var dialogue_mark: Sprite2D = $chatzone/dialogue_mark

func _ready() -> void:
	DialogueManager.get_current_scene = func(): return get_node(".")
	DialogueManager.dialogue_ended.connect(_on_dialogue_manager_dialogue_ended) # For checking if a dialogue ended
	dialogue_mark.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if player_in_chatzone and Input.is_action_just_pressed("interact"):
		dialogue_mark.visible = false
		player_cam.zoom = Vector2(6.0, 6.0)
		#player_cam.position.x = self.position.x
		#player_cam.position.y -= 20
		if player.dialogue_hardy == 0:
			DialogueManager.show_dialogue_balloon(resource, "start")
			player.dialogue_hardy = 1
		elif player.dialogue_hardy == 1:
			DialogueManager.show_dialogue_balloon(resource, "start2")
			player.dialogue_hardy = 2
		elif player.dialogue_hardy == 2:
			DialogueManager.show_dialogue_balloon(resource, "start3")
			player.dialogue_hardy = 3
		elif player.dialogue_hardy == 3:
			DialogueManager.show_dialogue_balloon(resource, "start4")
			player.dialogue_hardy = 4
		else:
			DialogueManager.show_dialogue_balloon(resource, "endloop")

func _on_chatzone_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player_in_chatzone = true
		dialogue_mark.visible = true

func _on_chatzone_body_exited(body: Node2D) -> void:
	player_in_chatzone = false
	dialogue_mark.visible = false
	
func _on_dialogue_manager_dialogue_ended(resource: DialogueResource) -> void:
	# Code to execute when dialogue ends
	dialogue_mark.visible = true
	player_cam.zoom = Vector2(4.0, 4.0)
	#player_cam.position = player.position 
