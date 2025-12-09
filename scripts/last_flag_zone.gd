extends Area2D

@onready var dialogue_mark: Sprite2D = $DialogueMark
@onready var root_level := get_tree().get_current_scene()
@onready var finish_text: Label = $finish_text
@onready var finish_time: Label = $finish_time

var player_in_chatzone = false

func _unhandled_input(event: InputEvent) -> void:
	if player_in_chatzone and Input.is_action_just_pressed("interact"):
		dialogue_mark.visible = false
		root_level.stopwatch_stopped = true
		finish_time.text = root_level.time_to_string()
		finish_text.visible = true
		finish_time.visible = true

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		dialogue_mark.visible = true
		player_in_chatzone = true



func _on_body_exited(body: Node2D) -> void:
	if body.name == "player":
		dialogue_mark.visible = false
