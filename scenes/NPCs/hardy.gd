extends AnimatedSprite2D

@onready var player := get_tree().current_scene.get_node("player") # get player from tree
var resource = load("res://dialogues/hardy1.dialogue")

func dialogue_logic():
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
