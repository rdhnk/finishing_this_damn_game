extends Area2D

@onready var timer: Timer = $Timer
@onready var player: CharacterBody2D = $"../../player"

func _on_body_entered(body: Node2D) -> void:
	#print("ded")
	#player.player_sprite.play("dead")
	player.alive = false
	player.dying()
	#timer.start()

func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
