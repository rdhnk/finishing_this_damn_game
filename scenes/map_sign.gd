extends Sprite2D

@onready var player := get_tree().current_scene.get_node("player") # get player from tree
var resource = load("res://dialogues/map_sign.dialogue")
@onready var map_lowres: Sprite2D = $MapLowres

func dialogue_logic():
	DialogueManager.show_dialogue_balloon(resource, "start")
	map_lowres.visible = true
