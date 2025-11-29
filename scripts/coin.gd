extends Area2D

@onready var sfx: AudioStreamPlayer2D = $sfx

func _on_body_entered(body: Node2D) -> void:
	print("get coin")
	sfx.play()		# Play sfx first ...
	self.hide() 	# ... then hide the sprite ...
	await get_tree().create_timer(0.5).timeout # ... wait 0.5 seconds ...
	queue_free() 	# ... then delete the node
