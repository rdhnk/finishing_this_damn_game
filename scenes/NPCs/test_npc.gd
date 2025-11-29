extends Sprite2D

var resource = load("res://dialogues/test_npc.dialogue")

func dialogue_logic():
	DialogueManager.show_dialogue_balloon(resource, "start")
