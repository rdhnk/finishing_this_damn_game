extends Node2D

var player
var player_in_chatzone = false
var is_chatting = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if player_in_chatzone and Input.is_action_just_pressed("ui_accept"):
		#print("chatting")
		is_chatting = true
		$Dialogue.start()

func _on_chat_detection_body_entered(body):
	if body.name == "player":
		print("ye enter")
		player = body
		player_in_chatzone = true
		print(player_in_chatzone)

func _on_chat_detection_body_exited(body):
	if body.name == "player":
		player_in_chatzone = false
		print(player_in_chatzone)

func _on_control_dialogue_finished():
	is_chatting = false
	player_in_chatzone = false
	print(is_chatting)
