extends Sprite2D

var resource = load("res://dialogues/outpost1_sign.dialogue")

func dialogue_logic():
	DialogueManager.show_dialogue_balloon(resource, "start")
