extends AnimatedSprite2D

@onready var player := get_tree().current_scene.get_node("player") # get player from tree
var resource = load("res://dialogues/shop_jacobi.dialogue")

func dialogue_logic():
	if player.dialogue_shop_jacobi == 0:
		DialogueManager.show_dialogue_balloon(resource, "start")
		player.dialogue_shop_jacobi = 1
	elif player.dialogue_shop_jacobi == 1:
		DialogueManager.show_dialogue_balloon(resource, "start2")
		player.dialogue_shop_jacobi = 2
	elif player.dialogue_shop_jacobi == 2:
		DialogueManager.show_dialogue_balloon(resource, "start3")
		player.dialogue_shop_jacobi = 3
	else:
		DialogueManager.show_dialogue_balloon(resource, "endloop")
