extends Area2D

@onready var player: CharacterBody2D = $"../player"

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		player.grappling_hook = true
