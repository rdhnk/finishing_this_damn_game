extends Area2D

@onready var player: CharacterBody2D = get_tree().current_scene.get_node("player")
@onready var sfx := $sfx
#var position := global_position

func _on_body_entered(body: Node2D) -> void:
	print("checkpoint")
	#print(self.global_position)
	sfx.play()
	player.respawn_position = self.global_position
